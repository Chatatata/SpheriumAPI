defmodule Spherium.TokenController do
  use Spherium.Web, :controller
  use Timex

  import Spherium.AuthenticationService

  alias Spherium.Passphrase
  alias Spherium.PassphraseInvalidation
  alias Spherium.User

  plug :scrub_params, "passkey" when action in [:create]

  def create(conn, %{"passkey" => passkey}) do
    query = from p in Passphrase,
            left_join: pi in PassphraseInvalidation, on: p.id == pi.target_passphrase_id,
            join: u in User, on: p.user_id == u.id,
            where: p.passkey == ^passkey and
                   is_nil(pi.inserted_at) and
                   p.inserted_at > ago(5, "month"),
            select: {u, p}

    case Repo.one(query) do
      nil ->
        conn
        |> send_resp(:forbidden, "Authentication not available.")
      {user, passphrase} ->
        conn = issue_token(conn, user, passphrase)

        conn
        |> put_status(:created)
        |> render("show.json", token: %{jwt: conn.assigns[:jwt], exp: conn.assigns[:exp], user_id: user.id, timestamp: Timex.now})
    end
  end
end