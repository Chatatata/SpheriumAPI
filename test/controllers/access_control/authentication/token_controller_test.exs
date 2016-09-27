defmodule Spherium.TokenControllerTest do
  use Spherium.ConnCase

  alias Spherium.Factory

  test "logs in user if credentials match", %{conn: conn} do
    user = Factory.insert(:user)
    conn = post conn, token_path(conn, :create), credentials: %{username: user.username, password: "123456"}

    data = json_response(conn, 200)["data"]

    assert data["jwt"]
    assert data["exp"]
    assert data["timestamp"]
  end

  test "does not log in user if credentials don't match", %{conn: conn} do
    user = Factory.insert(:user)

    conn = post conn, token_path(conn, :create), credentials: %{username: user.username, password: "1234567"}

    assert response(conn, 401) =~ "Invalid username/password combination."
  end

  test "does not log in user if username does not exist", %{conn: conn} do
    conn = post conn, token_path(conn, :create), credentials: %{username: "nonexisting", password: "1234567"}

    assert response(conn, 401) =~ "Invalid username/password combination."
  end
end
