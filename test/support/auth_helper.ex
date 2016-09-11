defmodule SpheriumWebService.AuthHelper do
  import Plug.Conn, only: [put_req_header: 3, assign: 3]

  alias SpheriumWebService.UserView

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
    |> put_req_header("authorization", "Bearer #{token}")
    |> assign(:jwt, token)
    |> put_req_header("x-expires", Integer.to_string(jwt["exp"]))
    |> assign(:exp, jwt["exp"])
  end
end
