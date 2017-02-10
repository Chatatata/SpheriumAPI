defmodule Spherium.PasswordControllerTest do
  use Spherium.ConnCase

  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias Spherium.User

  @fake_pw "456789"

  test "updates and renders chosen resource when data is valid", %{conn: conn, user: user} do
    conn = put conn, user_password_path(conn, :update, user), password: @fake_pw

    user = Repo.get!(User, user.id)

    assert json_response(conn, 200)["result"] == "ok"
    assert json_response(conn, 200)["user_id"] == "#{user.id}"
    assert checkpw(@fake_pw, user.password_digest)
  end

  test "rejects when invalid password change information is given", %{conn: conn, user: user} do
    conn = put conn, user_password_path(conn, :update, user), password: 12345

    assert conn.status == 422
  end
end
