defmodule Spherium.OneTimeCodeController do
  use Spherium.Web, :controller

  import Ecto.Changeset, only: [get_field: 2, put_change: 3]
  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias Spherium.OneTimeCode
  alias Spherium.Code
  alias Spherium.Credentials
  alias Spherium.User
  alias Spherium.Attempt
  alias Spherium.Passphrase

  plug :scrub_params, "credentials" when action in [:create]

  def create(conn, %{"credentials" => credentials}) do
    credentials_changeset = Credentials.changeset(%Credentials{}, credentials)

    ip_addr =
      conn.remote_ip
      |> Tuple.to_list
      |> Enum.join(".")

    if credentials_changeset.valid? do
      username = get_field(credentials_changeset, :username)
      password = get_field(credentials_changeset, :password)

      attempt_changeset = Attempt.changeset(%Attempt{}, %{username: username, ip_addr: ip_addr})

      case Repo.transaction(fn ->
        query = from u in User,
                where: u.username == ^username
                select: u

        case Repo.one(query) do
          nil ->
            Repo.insert!(attempt_changeset)
            Repo.rollback(:invalid_password)
          user ->
            unless checkpw(password, user.password_digest), do: Repo.rollback(:invalid_password)

            query = from p in Passphrase,
                    left_join: pi in PassphraseInvalidation, on: pi.passphrase_id == p.id,
                    where: p.user_id == ^user.id and is_nil(pi.id)

            if Repo.aggregate(query, :count, :id) == 5, do: Repo.rollback(:max_passphrases_reached)

            one_time_code_changeset =
              OneTimeCode.changeset(
                %OneTimeCode{},
                %{user_id: user.id,
                  code: Code.generate(),
                  device: get_field(credentials_changeset, :device),
                  user_agent: get_field(credentials_changeset, :user_agent)}
              )

            Repo.insert!(one_time_code_changeset)
        end
      end) do
        {:ok, one_time_code} ->
          attempt_changeset
          |> put_change(:success, true)
          |> Repo.insert!()

          conn
          |> put_status(:created)
          |> render("one_time_code.json", one_time_code: one_time_code)
        {:error, :max_passphrases_reached} ->
          send_resp(conn, :conflict, "Maximum number of passphrases available is reached (5).")
        {:error, :invalid_password} ->
          attempt_changeset
          |> Repo.insert!()

          send_resp(conn, :forbidden, "Invalid username/password combination.")
      end
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Spherium.ChangesetView, "error.json", changeset: credentials_changeset)
    end
  end
end
