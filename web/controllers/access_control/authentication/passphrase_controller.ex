defmodule Spherium.PassphraseController do
  use Spherium.Web, :controller

  import Ecto.Changeset, only: [get_field: 2, put_change: 3]
  import Spherium.CredentialValidationService

  alias Spherium.Passphrase
  alias Spherium.Credentials
  alias Spherium.Attempt

  plug :scrub_params, "credentials" when action in [:create]

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

      case check_credentials(username, password) do
        {:accepted, user} ->
          case Repo.transaction(fn ->
            query = from p in Passphrase,
                    where: p.user_id == ^user.id and p.valid?

            if Repo.aggregate(query, :count, :passkey) == 5, do: Repo.rollback(:max_passphrases_reached)

            attempt_changeset
            |> put_change(:success, true)
            |> Repo.insert!()

            passphrase_changeset = Passphrase.changeset(%Passphrase{}, %{user_id: user.id,
                                                                         device: get_field(credentials_changeset, :device),
                                                                         user_agent: get_field(credentials_changeset, :user_agent),
                                                                         valid?: true})

            Repo.insert!(passphrase_changeset)
          end) do
            {:ok, passphrase} ->
              conn
              |> put_status(:created)
              |> render("show.json", passphrase: passphrase)
            {:error, :max_passphrases_reached} ->
              conn
              |> send_resp(:unauthorized, "Maximum number of passphrases available is reached (5).")
          end
        _ ->
          attempt_changeset
          |> Repo.insert!()

          conn
          |> send_resp(:unauthorized, "Invalid username/password combination.")
      end
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Spherium.ChangesetView, "error.json", changeset: credentials_changeset)
    end
  end
end
