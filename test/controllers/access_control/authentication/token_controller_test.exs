defmodule Spherium.TokenControllerTest do
  use Spherium.ConnCase

  alias Spherium.Passkey
  alias Spherium.Factory

  @tag super_cow_powers: false

  test "generates token if passkey exists", %{conn: conn} do
    user = Factory.insert(:user)
    passphrase = Factory.insert(:passphrase, user: user)

    conn = post conn, token_path(conn, :create), passkey: passphrase.passkey

    data = json_response(conn, 201)["data"]

    assert data["jwt"]
    assert data["exp"]
    assert data["user_id"]
    assert data["timestamp"]
  end

  test "responds with 403 if passkey does not exist", %{conn: conn} do
    conn = post conn, token_path(conn, :create), passkey: Passkey.generate()

    data = response(conn, 403)
    assert data =~ "Authentication not available."
  end

  test "responds with 403 if underlying passphrase of passkey is invalidated", %{conn: conn} do
    user = Factory.insert(:user)
    passphrase = Factory.insert(:passphrase, user: user)
    invalidated_passphrase = Factory.insert(:passphrase, user: user)
    _passphrase_invalidation = Factory.insert(:passphrase_invalidation, passphrase: passphrase, target_passphrase: invalidated_passphrase)

    conn = post conn, token_path(conn, :create), passkey: invalidated_passphrase.passkey

    data = response(conn, 403)
    assert data =~ "Authentication not available."
  end

  test "responds with 403 if underlying passphrase of passkey is expired", %{conn: conn} do
    user = Factory.insert(:user)
    passphrase = Factory.insert(:passphrase, user: user, inserted_at: Ecto.DateTime.cast!("1970-01-01 00:00:00"))

    conn = post conn, token_path(conn, :create), passkey: passphrase.passkey

    data = response(conn, 403)
    assert data =~ "Authentication not available."
  end
end
