defmodule Spherium.PasswordControllerTest do
  use Spherium.ConnCase

  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias Spherium.User
  alias Spherium.Factory

  @fake_pw "456789"

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user = Factory.insert(:user)
    conn = put conn, user_password_path(conn, :update, user), password: @fake_pw

    fetched_user = Repo.get!(User, user.id)

    assert json_response(conn, 200)["result"] =~ "ok"
    assert json_response(conn, 200)["user_id"] == "#{user.id}"
    assert checkpw(@fake_pw, fetched_user.password_digest)
  end

  test "throws 404 when non-existing identifier is given to update", %{conn: conn} do
    assert_error_sent 404, fn ->
      put conn, user_password_path(conn, :update, -1), password: "456789"
    end
  end

  test "rejects when invalid password change information is given", %{conn: conn} do
    user = Factory.insert(:user)
    conn = put conn, user_password_path(conn, :update, user), password: 12345

    assert conn.status == 422
  end
end
