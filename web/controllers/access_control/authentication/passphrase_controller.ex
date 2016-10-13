defmodule Spherium.PassphraseController do
  use Spherium.Web, :controller

  import Ecto.Changeset, only: [get_field: 2, put_change: 3]
  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias Spherium.Passphrase
  alias Spherium.PassphraseInvalidation
  alias Spherium.Passkey
  alias Spherium.Credentials
  alias Spherium.Attempt
  alias Spherium.User

  plug :authenticate_user when action in [:index, :show]
  plug :authorize_user, [:all, :self] when action in [:index, :show]
  plug :scrub_params, "credentials" when action in [:create]

  def index(conn, _params) do
    passphrases = Repo.all(Passphrase)

    render conn, "index.json", passphrases: passphrases
  end

  def show(conn, %{"id" => id}) do
    passphrase = Repo.get!(Passphrase, id)

    unless conn.assigns[:permission_type] == :one and
           passphrase.user_id == conn.assigns[:user].id, do: raise InsufficientScopeError

    render conn, "show.json", passphrase: passphrase
  end

  def create(conn, %{"credentials" => credentials}) do
    credentials_changeset = Credentials.changeset(%Credentials{}, credentials)

    ip_addr =
      conn.remote_ip
      |> Tuple.to_list()
      |> Enum.join(".")

    if credentials_changeset.valid? do
      username = get_field(credentials_changeset, :username)
      password = get_field(credentials_changeset, :password)

      attempt_changeset = Attempt.changeset(%Attempt{}, %{username: username, ip_addr: ip_addr})

      case Repo.transaction(fn ->
        query = from u in User,
                where: u.username == ^username

        case Repo.one(query) do
          nil ->
            attempt_changeset
            |> Repo.insert!()

            Repo.rollback(:invalid_password)
          user ->
            unless checkpw(password, user.password_digest), do: Repo.rollback(:invalid_password)

            query = from p in Passphrase,
                    left_join: pi in PassphraseInvalidation, on: pi.passphrase_id == p.id,
                    where: p.user_id == ^user.id and is_nil(pi.id)

            if Repo.aggregate(query, :count, :id) == 5, do: Repo.rollback(:max_passphrases_reached)

            passphrase_changeset = Passphrase.changeset(%Passphrase{}, %{passkey: Passkey.generate(),
                                                                         user_id: user.id,
                                                                         device: get_field(credentials_changeset, :device),
                                                                         user_agent: get_field(credentials_changeset, :user_agent)})

            Repo.insert!(passphrase_changeset)
        end
      end) do
        {:ok, passphrase} ->
          attempt_changeset
          |> put_change(:success, true)
          |> Repo.insert!()

          conn
          |> put_status(:created)
          |> render("show.private.json", passphrase: passphrase)
        {:error, :max_passphrases_reached} ->
          conn
          |> send_resp(:conflict, "Maximum number of passphrases available is reached (5).")
        {:error, :invalid_password} ->
          attempt_changeset
          |> Repo.insert!()

          conn
          |> send_resp(:forbidden, "Invalid username/password combination.")
      end
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Spherium.ChangesetView, "error.json", changeset: credentials_changeset)
    end
  end
end
