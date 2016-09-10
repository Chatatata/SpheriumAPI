defmodule SpheriumWebService.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """
    import Plug.Conn, only: [put_req_header: 3, assign: 3]

  alias SpheriumWebService.Repo
  alias SpheriumWebService.User
  alias SpheriumWebService.UserView

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias SpheriumWebService.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]

      import SpheriumWebService.Router.Helpers

      # The default endpoint for testing
      @endpoint SpheriumWebService.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SpheriumWebService.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SpheriumWebService.Repo, {:shared, self()})
    end

    Repo.delete_all(User)
    user = User.changeset(%User{}, %{username: "test", password: "test", email: "test@mail.com"}) |> Repo.insert!()

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("accept", "application/json")
      |> issue_token(user)

    # IO.inspect conn

    {:ok, conn: conn}
  end

  defp issue_token(conn, user) do
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
