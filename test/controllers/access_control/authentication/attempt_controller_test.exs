defmodule Spherium.AttemptControllerTest do
  use Spherium.ConnCase

  alias Spherium.Factory

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, authentication_attempt_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    user = conn.assigns[:setup_user]
    attempt = Factory.insert(:attempt, username: user.username)

    conn = get conn, authentication_attempt_path(conn, :show, attempt)
    assert json_response(conn, 200)["data"] == %{"id" => attempt.id,
                                                 "username" => attempt.username,
                                                 "success" => attempt.success,
                                                 "ip_addr" => attempt.ip_addr}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, authentication_attempt_path(conn, :show, -1)
    end
  end
end
