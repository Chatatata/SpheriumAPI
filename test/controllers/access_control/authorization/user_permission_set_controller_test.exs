defmodule Spherium.UserPermissionSetControllerTest do
  use Spherium.ConnCase

  alias Spherium.User
  alias Spherium.PermissionSetGrant
  alias Spherium.Factory

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "shows permission set of a user", %{conn: conn} do
    user = Factory.insert(:user)
    permission = Factory.insert(:permission)
    permission_set = Factory.insert(:permission_set, user_id: user.id, permissions: [permission])
    tight_user = Factory.insert(:user, permission_set_id: permission_set.id)

    conn = get conn, user_user_permission_set_path(conn, :show, tight_user)

    assert json_response(conn, 200)["data"] == %{"id" => permission_set.id,
                                                 "name" => permission_set.name,
                                                 "description" => permission_set.description,
                                                 "user_id" => user.id,
                                                 "grant_power" => permission_set.grant_power,
                                                 "permissions" => [%{
                                                    "id" => permission.id,
                                                    "required_grant_power" => permission.required_grant_power,
                                                    "controller_name" => permission.controller_name,
                                                    "controller_action" => permission.controller_action,
                                                    "type" => permission.type
                                                   }]
                                                 }
  end

  test "throws 404 when user lacking of it", %{conn: conn} do
    assert_error_sent 404, fn ->
      user = Factory.insert(:user)

      get conn, user_user_permission_set_path(conn, :show, user)
    end
  end

  test "throws 404 when user is non-existing", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  test "assigns a permission set to a user and creates a new permission set grant", %{conn: conn} do
    user = Factory.insert(:user)
    permission = Factory.insert(:permission)
    permission_set = Factory.insert(:permission_set, user_id: user.id, permissions: [permission])
    tight_user = Factory.insert(:user, permission_set_id: permission_set.id)

    conn = put conn, user_user_permission_set_path(conn, :update, tight_user), permission_set_id: permission_set.id

    assert json_response(conn, 200)["data"] == %{"id" => permission_set.id,
                                                 "name" => permission_set.name,
                                                 "description" => permission_set.description,
                                                 "user_id" => user.id,
                                                 "grant_power" => permission_set.grant_power,
                                                 "permissions" => [%{
                                                    "id" => permission.id,
                                                    "required_grant_power" => permission.required_grant_power,
                                                    "controller_name" => permission.controller_name,
                                                    "controller_action" => permission.controller_action,
                                                    "type" => permission.type
                                                   }]
                                                 }

    assert Repo.get_by(User, %{permission_set_id: permission_set.id, id: tight_user.id})
    assert Repo.get_by(PermissionSetGrant, %{target_user_id: tight_user.id, user_id: conn.assigns[:setup_user].id, permission_set_id: permission_set.id})
  end

  test "throws 404 when non-existing permission set is given to be assigned", %{conn: conn} do
    user = Factory.insert(:user)
    permission = Factory.insert(:permission)
    permission_set = Factory.insert(:permission_set, user_id: user.id, permissions: [permission])
    tight_user = Factory.insert(:user, permission_set_id: permission_set.id)

    conn = put conn, user_user_permission_set_path(conn, :update, tight_user), permission_set_id: -1

    assert conn.status == 404
    assert conn.resp_body == "Permission set with given identifier not found."
    refute Repo.get_by(PermissionSetGrant, %{target_user_id: tight_user.id, user_id: user.id, permission_set_id: permission_set.id})
  end

  test "throws 404 when non-existing user is given to update", %{conn: conn} do
    user = Factory.insert(:user)
    permission_set = Factory.insert(:permission_set, user_id: user.id)

    conn = put conn, user_user_permission_set_path(conn, :update, -1), permission_set_id: permission_set.id

    assert conn.status == 404
    assert conn.resp_body == "User not found."
  end

  test "unassigns user's permission set", %{conn: conn} do
    user = Factory.insert(:user)
    permission_set = Factory.insert(:permission_set, user_id: user.id)
    tight_user = Factory.insert(:user, permission_set_id: permission_set.id)

    conn = delete conn, user_user_permission_set_path(conn, :delete, tight_user)

    assert conn.status == 204
    assert conn.resp_body == "Permission set successfully unassigned from user."
    refute Repo.get(User, tight_user.id).permission_set_id
  end

  test "throws 404 when non-existing user's permission set is attempted to be deleted", %{conn: conn} do
    conn = delete conn, user_user_permission_set_path(conn, :delete, -1)

    assert conn.status == 404
    assert conn.resp_body == "User not found."
  end
end
