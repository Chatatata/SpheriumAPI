defmodule Spherium.PassphraseControllerTest do
  use Spherium.ConnCase

  alias Spherium.Factory

  @tag super_cow_powers: false

  test "creates a new passphrase with valid credentials", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")

    conn = post conn, passphrase_path(conn, :create), credentials: %{username: user.username,
                                                                     password: "123456",
                                                                     device: Ecto.UUID.generate(),
                                                                     user_agent: "Testing user agent, ExUnit rulz!."}

    data = json_response(conn, 201)["data"]

    assert data
    assert data["passkey"]
    assert data["device"]
    assert data["user_agent"] =~ "Testing user agent, ExUnit rulz!."
  end

  test "log in user if user has 5 passphrases but 3 of them is valid", %{conn: conn} do
    user = Factory.insert(:user)

    passphrases = Factory.insert_list(3, :passphrase, user_id: user.id)

    invalidated_passphrases = Factory.insert_list(2, :passphrase, user_id: user.id)
    Factory.insert(:passphrase_invalidation, passphrase_id: Enum.at(passphrases, 0).id, target_passphrase_id: Enum.at(invalidated_passphrases, 0).id)
    Factory.insert(:passphrase_invalidation, passphrase_id: Enum.at(passphrases, 0).id, target_passphrase_id: Enum.at(invalidated_passphrases, 1).id)

    conn = post conn, passphrase_path(conn, :create), credentials: %{username: user.username,
                                                                     password: "123456",
                                                                     device: Ecto.UUID.generate(),
                                                                     user_agent: "Testing user agent, ExUnit rulz!."}

    data = json_response(conn, 201)["data"]

    assert data
    assert data["passkey"]
    assert data["device"]
    assert data["user_agent"] =~ "Testing user agent, ExUnit rulz!."
  end

  test "does not log in user if credentials don't match", %{conn: conn} do
    user = Factory.insert(:user)

    conn = post conn, passphrase_path(conn, :create), credentials: %{username: user.username,
                                                                     password: "wrong_password",
                                                                     device: Ecto.UUID.generate(),
                                                                     user_agent: "Testing user agent, ExUnit rulz!."}

    assert response(conn, 403) =~ "Invalid username/password combination."
  end

  test "does not log in user if username does not exist", %{conn: conn} do
    conn = post conn, passphrase_path(conn, :create), credentials: %{username: "test",
                                                                     password: "some_password",
                                                                     device: Ecto.UUID.generate(),
                                                                     user_agent: "Testing user agent, ExUnit rulz!."}

    assert response(conn, 403) =~ "Invalid username/password combination."
  end

  test "does not log in user if user already has 5 passphrases", %{conn: conn} do
    user = Factory.insert(:user)

    Factory.insert_list(5, :passphrase, user_id: user.id)

    conn = post conn, passphrase_path(conn, :create), credentials: %{username: user.username,
                                                                     password: "123456",
                                                                     device: Ecto.UUID.generate(),
                                                                     user_agent: "Testing user agent, ExUnit rulz!."}

    assert response(conn, 409) =~ "Maximum number of passphrases available is reached (5)."
  end
end
