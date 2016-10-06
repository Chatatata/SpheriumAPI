defmodule Spherium.AuthenticationService do
  import Plug.Conn, only: [put_resp_header: 3, assign: 3]

  alias Spherium.UserView
  alias Spherium.PassphraseView

  def issue_token(conn, user, passphrase) do
    user_view = UserView.render("user.private.json", user: user)
    passphrase_view = PassphraseView.render("passphrase.min.json", passphrase: passphrase) |> Map.drop([:inserted_at])

    jwk = %{
      "kty" => "oct",
      "k" => :base64url.encode("secret")
    }

    jws = %{
      "alg" => "HS256",
      "typ" => "JWT"
    }

    payload = %{"iss" => "spherium",
                "exp" => :os.system_time(:seconds) + (60 * 60),   # TODO: Configurable property
                "sub" => "access"}

    jwt =
      payload
      |> Map.merge(user_view)
      |> Map.merge(passphrase_view)

    {_, token} = JOSE.JWT.sign(jwk, jws, jwt)
                 |> JOSE.JWS.compact()

    conn
    |> put_resp_header("authorization", "Bearer #{token}")
    |> assign(:jwt, token)
    |> put_resp_header("x-expires", Integer.to_string(jwt["exp"]))
    |> assign(:exp, jwt["exp"])
  end
end
