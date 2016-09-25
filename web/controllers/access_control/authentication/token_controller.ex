defmodule Spherium.TokenController do
  use Spherium.Web, :controller
  use Timex

  import Ecto.Changeset, only: [put_change: 3, get_field: 2]

  alias Spherium.Attempt
  alias Spherium.Credentials
  alias Spherium.CredentialValidationService
  alias Spherium.AuthenticationService

  def create(conn, %{"credentials" => credentials}) do
    credentials = Credentials.changeset(%Credentials{}, credentials)

    ip_addr =
      conn.remote_ip
      |> Tuple.to_list()
      |> Enum.join(".")

    if credentials.valid? do
      changeset = Attempt.changeset(%Attempt{}, %{username: get_field(credentials, :username), ip_addr: ip_addr})

      case CredentialValidationService.check_credentials(get_field(credentials, :username), get_field(credentials, :password)) do
        {:accepted, user} ->
          changeset
          |> put_change(:success, true)
          |> Repo.insert!()

          conn
          |> AuthenticationService.issue_token(user)
          |> render("show.json", token: %{jwt: conn.assigns[:jwt], exp: conn.assigns[:exp], timestamp: Timex.now})
        _ ->
          changeset
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
