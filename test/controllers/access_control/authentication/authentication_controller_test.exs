defmodule Spherium.AuthenticationControllerTest do
  use Spherium.ConnCase

  @tag super_cow_powers: false

  alias Spherium.Factory

  test "returns passphrase if user preferred insecure authentication scheme", %{conn: conn} do
    user = Factory.insert(:user, password: "123456", authentication_scheme: :insecure)

    conn = post conn,
                authentication_path(conn, :create),
                credentials: %{
                  username: user.username,
                  password: "123456",
                  device: Ecto.UUID.generate(),
                  user_agent: "Test user agent"
                }

    data = json_response(conn, 201)["data"]

    assert data["user_id"] == user.id
    assert data["authentication_scheme"] == "insecure"
    assert data["passphrase_id"]
    assert data["passkey"]
  end

  test "returns user identifier with two factor authentication over SMS scheme", %{conn: conn} do
    user = Factory.insert(:user, password: "123456", authentication_scheme: :two_factor_over_sms)

    conn = post conn,
                authentication_path(conn, :create),
                credentials: %{
                  username: user.username,
                  password: "123456",
                  device: Ecto.UUID.generate(),
                  user_agent: "Test user agent"
                }

    data = json_response(conn, 201)["data"]

    assert data["user_id"] == user.id
    assert data["authentication_scheme"] == "two_factor_over_sms"
    refute data["passphrase_id"]
    refute data["passkey"]
  end

  test "returns user identifier with two factor authentication over TBC scheme", %{conn: conn} do
    user = Factory.insert(:user, password: "123456", authentication_scheme: :two_factor_over_tbc)

    conn = post conn,
                authentication_path(conn, :create),
                credentials: %{
                  username: user.username,
                  password: "123456",
                  device: Ecto.UUID.generate(),
                  user_agent: "Test user agent"
                }

    data = json_response(conn, 201)["data"]

    assert data["user_id"] == user.id
    assert data["authentication_scheme"] == "two_factor_over_tbc"
    refute data["passphrase_id"]
    refute data["passkey"]
  end

  test "returns 422 on invalid credentials", %{conn: conn} do
    conn = post conn,
                authentication_path(conn, :create),
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
                authentication_path(conn, :create),
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
                authentication_path(conn, :create),
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
                authentication_path(conn, :create),
                credentials: %{
                  username: user.username,
                  password: "123456",
                  device: Ecto.UUID.generate(),
                  user_agent: "Test user agent"
                }

    assert text_response(conn, :too_many_requests) =~ "OTC quota per 15 minutes is reached (2)."
  end
end
