defmodule Spherium.PermissionControllerTest do
  use Spherium.ConnCase

  alias Spherium.Permission

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, permission_path(conn, :index)

    assert is_list(json_response(conn, 200)["data"])
  end

  test "shows an entry", %{conn: conn} do
    query = from p in Permission,
            order_by: fragment("random()"),
            limit: 1

    [permission | _] = Repo.all(query)

    conn = get conn, permission_path(conn, :show, permission.id)

    assert json_response(conn, 200)["data"] == %{"id" => permission.id,
                                                 "required_grant_power" => permission.required_grant_power,
                                                 "controller_name" => permission.controller_name,
                                                 "controller_action" => permission.controller_action,
                                                 "type" => permission.type}
  end
end
