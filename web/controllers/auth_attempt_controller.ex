defmodule SpheriumWebService.AuthAttemptController do
  use SpheriumWebService.Web, :controller

  alias SpheriumWebService.AuthAttempt
  alias SpheriumWebService.Credentials
  alias SpheriumWebService.CredentialValidationService

  import Ecto.Changeset, only: [put_change: 3, get_field: 2]
  plug :scrub_params, "credentials" when action in [:create]

  def index(conn, _params) do
    auth_attempts = Repo.all(AuthAttempt)
    render(conn, "index.json", auth_attempts: auth_attempts)
  end

  def create(conn, %{"credentials" => credentials}) do
    credentials = Credentials.changeset(%Credentials{}, credentials)

    ip_addr =
      conn.peer
      |> elem(0)
      |> Tuple.to_list()
      |> Enum.join(".")

    if credentials.valid? do
      changeset = AuthAttempt.changeset(%AuthAttempt{}, %{username: get_field(credentials, :username), ip_addr: ip_addr})

      case CredentialValidationService.check_credentials(get_field(credentials, :username), get_field(credentials, :password)) do
        {:accepted, user} ->
          changeset
          |> put_change(:success, true)
          |> Repo.insert!()

          conn = Guardian.Plug.api_sign_in conn, user
          jwt = Guardian.Plug.current_token conn

          case Guardian.Plug.claims conn do
            {:ok, claims} ->

              conn
              |> put_resp_header("authorization", "Bearer #{jwt}")
              |> put_resp_header("x-expires", Integer.to_string(claims["exp"]))
              |> render("artifacts.json", %{artifacts: %{user: user, jwt: jwt, exp: claims["exp"]}})
          end
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

  def show(conn, %{"id" => id}) do
    auth_attempt = Repo.get!(AuthAttempt, id)
    render(conn, "show.json", auth_attempt: auth_attempt)
  end
end
