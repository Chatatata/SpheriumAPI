defmodule Spherium.PassphraseController do
  use Spherium.Web, :controller

  import Ecto.Changeset, only: [get_field: 2, put_change: 3]
  import Spherium.CredentialValidationService

  alias Spherium.Passphrase
  alias Spherium.Credentials
  alias Spherium.Attempt

  plug :scrub_params, "credentials" when action in [:create]

  def create(conn, %{"credentials" => credentials}) do
    credentials = Credentials.changeset(%Credentials{}, credentials)

    ip_addr =
      conn.remote_ip
      |> Tuple.to_list()
      |> Enum.join(".")

    if credentials.valid? do
      attempt_changeset = Attempt.changeset(%Attempt{}, %{username: get_field(credentials, :username), ip_addr: ip_addr})

      case check_credentials(get_field(credentials, :username), get_field(credentials, :password)) do
        {:accepted, user} ->
          attempt_changeset
          |> put_change(:success, true)
          |> Repo.insert!()

          passphrase_changeset = Passphrase.changeset(%Passphrase{}, %{user_id: user.id,
                                                                       device: get_field(credentials, :device),
                                                                       user_agent: get_field(credentials, :user_agent),
                                                                       valid?: true})

          passphrase = Repo.insert!(passphrase_changeset)

          conn
          |> put_status(:created)
          |> render("show.json", passphrase: passphrase)
        _ ->
          attempt_changeset
          |> Repo.insert!()

          conn
          |> send_resp(:unauthorized, "Invalid username/password combination.")
      end
    else
      conn
      |> send_resp(:bad_request, "Invalid parameters.")
    end
  end
end
