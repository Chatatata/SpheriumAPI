defmodule SpheriumWebService.PermissionSetControllerTest do
  use SpheriumWebService.ConnCase

  alias SpheriumWebService.PermissionSet
  alias SpheriumWebService.Factory

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, permission_set_path(conn, :index)

    assert json_response(conn, 200)["data"] == []
  end

  test "shows permission set without any permission", %{conn: conn} do
    user = Factory.insert(:user)
    permission_set = Factory.insert(:permission_set, user_id: user.id)
    conn = get conn, permission_set_path(conn, :show, permission_set)

    assert json_response(conn, 200)["data"] == %{"id" => permission_set.id,
                                                 "name" => permission_set.name,
                                                 "description" => permission_set.description,
                                                 "grant_power" => permission_set.grant_power,
                                                 "user_id" => permission_set.user_id,
                                                 "permissions" => []}
  end

  test "shows permission set with permissions", %{conn: conn} do
    user = Factory.insert(:user)
    permissions = Factory.insert_list(25, :permission)
    permission_set = Factory.insert(:permission_set, permissions: permissions, user_id: user.id)
    conn = get conn, permission_set_path(conn, :show, permission_set)

    assert json_response(conn, 200)["data"] == %{"id" => permission_set.id,
                                                 "name" => permission_set.name,
                                                 "description" => permission_set.description,
                                                 "grant_power" => permission_set.grant_power,
                                                 "user_id" => permission_set.user_id,
                                                 "permissions" => Phoenix.View.render_many(permissions, SpheriumWebService.PermissionView, "permission.json")
                                                                  |> Enum.map(&Enum.reduce(&1, %{}, fn {key, val}, acc ->
                                                                                                      Map.put(acc, Atom.to_string(key), val)
                                                                                                    end))}


  end

  test "renders page not found when permission_set with given id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, permission_set_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    permissions = Factory.insert_list(12, :permission)
    permission_ids = Enum.map(permissions, &(&1.id))

    conn = post conn, permission_set_path(conn, :create), permission_set: %{name: "on_create",
                                                                            description: "on_create description",
                                                                            grant_power: 200,
                                                                            permission_ids: permission_ids}

    data = json_response(conn, 201)["data"]

    assert data["id"]
    assert data["name"] == "on_create"
    assert data["description"] == "on_create description"
    assert data["grant_power"] == 200
    assert data["permissions"] == Phoenix.View.render_many(permissions, SpheriumWebService.PermissionView, "permission.json")
                                  |> Enum.map(&Enum.reduce(&1, %{}, fn {key, val}, acc ->
                                                                      Map.put(acc, Atom.to_string(key), val)
                                                                    end))
  end

  test "does not create resource and returns 422 when user identifier is given", %{conn: conn} do
    user = Factory.insert(:user)
    permissions = Factory.insert_list(12, :permission)
    permission_ids = Enum.map(permissions, &(&1.id))

    conn = post conn, permission_set_path(conn, :create), permission_set: %{name: "on_create",
                                                                            description: "on_create description",
                                                                            grant_power: 200,
                                                                            user_id: user.id,
                                                                            permission_ids: permission_ids}

    assert conn.status == 422
    assert conn.resp_body =~ "User identifier field is not allowed."
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    user = Factory.insert(:user)

    conn = post conn, permission_set_path(conn, :create), permission_set: %{name: "default",
                                                                            description: "default description",
                                                                            grant_power: 1001,
                                                                            user_id: user.id,
                                                                            permission_ids: []}

    assert conn.status == 422
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user = Factory.insert(:user)
    permissions = Factory.insert_list(20, :permission)
    permission_set = Factory.insert(:permission_set, user_id: user.id)

    conn = put conn, permission_set_path(conn, :update, permission_set), permission_set: %{name: "default",
                                                                                           description: "default description",
                                                                                           grant_power: 900,
                                                                                           permission_ids: Enum.map(permissions, &(&1.id))}

    data = json_response(conn, 200)["data"]

    assert data["name"] == "default"
    assert data["description"] == "default description"
    assert data["grant_power"] == 900
  end

  test "returns 422 when user identifier field is given", %{conn: conn} do
    user = Factory.insert(:user)
    permissions = Factory.insert_list(20, :permission)
    permission_set = Factory.insert(:permission_set, user_id: user.id)
    second_user = Factory.insert(:user)

    conn = put conn, permission_set_path(conn, :update, permission_set), permission_set: %{name: "default",
                                                                                           description: "default description",
                                                                                           grant_power: 900,
                                                                                           user_id: second_user.id,
                                                                                           permission_ids: Enum.map(permissions, &(&1.id))}

    assert conn.status == 422
  end

  test "throws 404 when non-existing identifier is given to update", %{conn: conn} do
    assert_error_sent 404, fn ->
      permissions = Factory.insert_list(20, :permission)
      put conn, permission_set_path(conn, :update, -1), permission_set: %{name: "default",
                                                                          description: "default description",
                                                                          grant_power: 900,
                                                                          permission_ids: Enum.map(permissions, &(&1.id))}
    end
  end

  test "deletes chosen resource", %{conn: conn} do
    user = Factory.insert(:user)
    permission_set = Factory.insert(:permission_set, user_id: user.id)
    conn = delete conn, permission_set_path(conn, :delete, permission_set)

    assert response(conn, 204)
    refute Repo.get(PermissionSet, permission_set.id)
  end

  test "throws 404 when non-existing identifier is given to delete", %{conn: conn} do
    assert_error_sent 404, fn ->
      delete conn, permission_set_path(conn, :delete, -1)
    end
  end
end
