defmodule Spherium.TokenController do
  use Spherium.Web, :controller
  use Timex

  import Spherium.AuthenticationService

  alias Spherium.Passphrase
  alias Spherium.User

  def create(conn, %{"passkey" => passkey}) do
    query = from p in Passphrase,
            join: u in User, on: u.id == p.user_id,
            where: p.passkey == ^passkey and p.valid?,
            select: u

    user = Repo.one!(query)

    conn =
      conn
      |> issue_token(user)

    conn
    |> put_status(:created)
    |> render("show.json", token: %{jwt: conn.assigns[:jwt], exp: conn.assigns[:exp], user_id: user.id, timestamp: Timex.now})
  end
end
