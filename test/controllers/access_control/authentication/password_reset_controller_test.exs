defmodule Spherium.PasswordResetControllerTest do
  use Spherium.ConnCase

  alias Spherium.Factory

  @tag super_cow_powers: false

  test "lists zero entry on index", %{conn: conn} do
    user = Factory.insert(:user)
    # password_resets = Factory.insert_list(2, :password_reset, user_id: user.id)

    conn = get conn, user_user_password_password_reset_path(conn, :index, user.id)

    assert json_response(conn, 200)["data"] == []
  end

  test "lists all entries on index", %{conn: conn} do
    user = Factory.insert(:user)
    password_reset = Factory.insert(:password_reset, user_id: user.id)

    conn = get conn, user_user_password_password_reset_path(conn, :index, user.id)

    assert json_response(conn, 200)["data"] == [%{"user_id" => user.id, "id" => password_reset.id}]
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    user = Factory.insert(:user)

    conn = post conn, user_user_password_password_reset_path(conn, :create, user.id)

    data = json_response(conn, 201)["data"]

    assert data["id"]
    assert data["user_id"] == user.id
  end

  test "does not create resource and returns 422 when user with identifier does not exist", %{conn: conn} do
    conn = post conn, user_user_password_password_reset_path(conn, :create, -1)

    assert conn.status == 422
  end
end
