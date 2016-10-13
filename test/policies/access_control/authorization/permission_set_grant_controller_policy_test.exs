defmodule Spherium.PermissionSetGrantControllerPolicyTests do
  use Spherium.PolicyCase

  alias Spherium.Factory
  alias Spherium.PermissionSetGrantControllerPolicy

  test "user wants to access all permission set grants", %{conn: conn} do
    conn = fetch_query_params(conn)

    refute PermissionSetGrantControllerPolicy.index(conn, nil, :self)
  end

  test "user wants to access his/her permission set grants", %{conn: conn} do
    user = conn.assigns[:user]

    conn =
      build_conn(:get, "/?target_user_id=" <> Integer.to_string(user.id))
      |> fetch_query_params()
      |> assign(:user, user)

    assert PermissionSetGrantControllerPolicy.index(conn, nil, :self)
  end

  test "user wants to access others permission set grants", %{conn: conn} do
    user = conn.assigns[:user]
    other_user = Factory.insert(:user)

    conn =
      build_conn(:get, "/?target_user_id=" <> Integer.to_string(other_user.id))
      |> fetch_query_params()
      |> assign(:user, user)

    refute PermissionSetGrantControllerPolicy.index(conn, nil, :self)
  end
end
