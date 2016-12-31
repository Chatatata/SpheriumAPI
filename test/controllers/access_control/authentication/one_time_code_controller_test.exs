defmodule Spherium.OneTimeCodeControllerTest do
  use Spherium.ConnCase

  alias Spherium.Factory

  @tag super_cow_powers: false

  test "generates an OTC to the user", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")

    conn = post conn,
                one_time_code_path(conn, :create),
                credentials: %{
                  username: user.username,
                  password: "123456",
                  device: Ecto.UUID.generate(),
                  user_agent: "Test user agent"
                }

    assert json_response(conn, 201)["user_id"] == user.id
  end

  test "returns 422 on invalid credentials", %{conn: conn} do
    conn = post conn,
                one_time_code_path(conn, :create),
                credentials: %{
                  username: "username",
                  device: Ecto.UUID.generate(),
                  user_agent: "Test user agent"
                }

    assert json_response(conn, 422)["errors"]["password"] == ["can't be blank"]
  end

  test "returns 403 on invalid username/password combination", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")

    conn = post conn,
                one_time_code_path(conn, :create),
                credentials: %{
                  username: user.username,
                  password: "1234567",
                  device: Ecto.UUID.generate(),
                  user_agent: "Test user agent"
                }

    assert text_response(conn, :forbidden) =~ "Invalid username/password combination."
  end

  test "returns 409 when passphrase quota exceeded", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")

    otcs = Factory.insert_list(5, :one_time_code, user_id: user.id)
    Enum.each(otcs, &Factory.insert(:passphrase, one_time_code_id: &1.id))

    conn = post conn,
                one_time_code_path(conn, :create),
                credentials: %{
                  username: user.username,
                  password: "123456",
                  device: Ecto.UUID.generate(),
                  user_agent: "Test user agent"
                }

    assert text_response(conn, :conflict) =~ "Maximum number of passphrases available is reached (5)."
  end

  test "returns 429 when OTC quota exceeded", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")

    Factory.insert_list(2, :one_time_code, user_id: user.id)

    conn = post conn,
                one_time_code_path(conn, :create),
                credentials: %{
                  username: user.username,
                  password: "123456",
                  device: Ecto.UUID.generate(),
                  user_agent: "Test user agent"
                }

    assert text_response(conn, :too_many_requests) =~ "OTC quota per 15 minutes is reached (2)."
  end
end
