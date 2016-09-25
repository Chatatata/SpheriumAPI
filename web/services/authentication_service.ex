defmodule Spherium.AuthenticationService do
  import Plug.Conn, only: [put_resp_header: 3, assign: 3]

  alias Spherium.UserView

  def issue_token(conn, user) do
    view = UserView.render_private("user.json", %{user: user})

    jwk = %{
      "kty" => "oct",
      "k" => :base64url.encode("secret")
    }

    jws = %{
      "alg" => "HS256",
      "typ" => "JWT"
    }

    jwt = Map.merge(%{
      "iss" => "spherium",
      "exp" => :os.system_time(:seconds) + (60 * 60),   # TODO: Configurable property
      "sub" => "access"
    }, view)

    {_, token} = JOSE.JWT.sign(jwk, jws, jwt)
                 |> JOSE.JWS.compact()

    conn
    |> put_resp_header("authorization", "Bearer #{token}")
    |> assign(:jwt, token)
    |> put_resp_header("x-expires", Integer.to_string(jwt["exp"]))
    |> assign(:exp, jwt["exp"])
  end
end
