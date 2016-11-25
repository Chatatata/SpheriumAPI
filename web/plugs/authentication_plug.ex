defmodule Spherium.AuthenticationPlug do
  use Spherium.Web, :plug

  alias Spherium.User

  def authenticate_user(conn, _opts) do
    jwk = JOSE.JWK.from(%{
      "kty" => "oct",
      "k" => :base64url.encode("secret")
    })

    case Plug.Conn.get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case JOSE.JWS.verify(jwk, token) do
          {true, payload, _jws} ->
            opts = Poison.decode!(payload)

            conn
            |> Plug.Conn.assign(:user, %User{id: opts["id"],
                                             username: opts["username"],
                                             email: opts["email"],
                                             inserted_at: Ecto.DateTime.cast!(opts["created_at"])})
            |> Plug.Conn.assign(:passphrase_id, opts["passphrase_id"])
          _ ->
            conn
            |> Plug.Conn.halt()
            |> Plug.Conn.send_resp(:forbidden, "Invalid token.")
        end
      _ ->
        conn
        |> Plug.Conn.halt()
        |> Plug.Conn.send_resp(:forbidden, "No token found.")
    end
  end
end
