defmodule SpheriumWebService.PermissionControllerTest do
  use SpheriumWebService.ConnCase

  alias SpheriumWebService.Factory

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, permission_path(conn, :index)

    assert json_response(conn, 200)["data"] == []
  end

  test "shows an entry", %{conn: conn} do
    permission = Factory.insert(:permission)
    conn = get conn, permission_path(conn, :show, permission)

    assert json_response(conn, 200)["data"] == %{"id" => permission.id,
                                                 "required_grant_power" => permission.required_grant_power,
                                                 "controller_name" => permission.controller_name,
                                                 "controller_action" => permission.controller_action,
                                                 "type" => permission.type}
  end

  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
  #   permission = Factory.insert(:permission)
  #   conn = put conn, permission_path(conn, :update, permission), permission: %{required_grant_power: 300, }
  #
  #   assert json_response(conn, 200)["data"]["id"]
  #   assert Repo.get_by(permission, %{publisher_id: permission.publisher_id, user_id: permission.user_id})
  # end
end
