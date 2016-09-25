defmodule Spherium.PermissionSetGrantControllerTest do
  use Spherium.ConnCase

  alias Spherium.Factory

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, permission_set_grant_path(conn, :index)

    assert json_response(conn, 200)["data"] == []
  end

  test "shows permission set grant with given identifier", %{conn: conn} do
    user = Factory.insert(:user)
    permissions = Factory.insert_list(20, :permission)
    permission_set = Factory.insert(:permission_set, user_id: user.id, permissions: permissions)
    target_user = Factory.insert(:user)
    permission_set_grant = Factory.insert(:permission_set_grant, user_id: user.id, target_user_id: target_user.id, permission_set_id: permission_set.id)

    conn = get conn, permission_set_grant_path(conn, :show, permission_set_grant)

    data = json_response(conn, 200)["data"]

    assert data["authority_id"] == user.id
    assert data["grant_target_id"] == target_user.id
    assert data["permission_set_id"] == permission_set.id
  end

  test "renders page not found when permission_set with given id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, permission_set_grant_path(conn, :show, -1)
    end
  end
end
