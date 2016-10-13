defmodule Spherium.AttemptControllerPolicyTest do
  use Spherium.PolicyCase

  alias Spherium.AttemptControllerPolicy

  test "user with self permission access all attempts", %{conn: conn} do
    conn = fetch_query_params(conn)

    refute AttemptControllerPolicy.index(conn, nil, :self)
  end

  test "user with self permission access self attempts", %{conn: conn} do
    user = conn.assigns[:user]

    conn =
      build_conn(:get, "/?username=" <> user.username)
      |> assign(:user, user)
      |> fetch_query_params()

    assert AttemptControllerPolicy.index(conn, nil, :self)
  end
end
