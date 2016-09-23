defmodule SpheriumWebService.AuthAttemptControllerTest do
  use SpheriumWebService.ConnCase

  alias SpheriumWebService.Factory

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, auth_attempt_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    user = Factory.insert(:user)
    auth_attempt = Factory.insert(:auth_attempt, username: user.username)

    conn = get conn, auth_attempt_path(conn, :show, auth_attempt)
    assert json_response(conn, 200)["data"] == %{"id" => auth_attempt.id,
                                                 "username" => auth_attempt.username,
                                                 "success" => auth_attempt.success,
                                                 "ip_addr" => auth_attempt.ip_addr}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, auth_attempt_path(conn, :show, -1)
    end
  end

  test "logs in user if credentials match", %{conn: conn} do
    user = Factory.insert(:user)
    conn = post conn, auth_attempt_path(conn, :create), credentials: %{username: user.username, password: "123456"}

    data = json_response(conn, 200)["data"]

    assert data["user"]
    assert data["jwt"]
    assert data["exp"]
    assert data["date"]
  end

  test "does not log in user if credentials don't match", %{conn: conn} do
    user = Factory.insert(:user)

    conn = post conn, auth_attempt_path(conn, :create), credentials: %{username: user.username, password: "1234567"}

    assert response(conn, 401) =~ "Invalid username/password combination."
  end

  test "does not log in user if username does not exist", %{conn: conn} do
    conn = post conn, auth_attempt_path(conn, :create), credentials: %{username: "nonexisting", password: "1234567"}

    assert response(conn, 401) =~ "Invalid username/password combination."
  end
end
