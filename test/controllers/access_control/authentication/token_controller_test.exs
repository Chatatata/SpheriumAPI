defmodule Spherium.TokenControllerTest do
  use Spherium.ConnCase

  alias Spherium.Passkey
  alias Spherium.Factory

  @tag super_cow_powers: false

  test "generates token if passkey exists", %{conn: conn} do
    user = Factory.insert(:user)
    otc = Factory.insert(:one_time_code, user: user)
    passphrase = Factory.insert(:passphrase, one_time_code: otc)

    conn = post conn, authentication_token_path(conn, :create), passkey: passphrase.passkey

    data = json_response(conn, 201)["data"]

    assert data["jwt"]
    assert data["exp"]
    assert data["user_id"]
    assert data["timestamp"]
  end

  test "responds with 403 if passkey does not exist", %{conn: conn} do
    conn = post conn, authentication_token_path(conn, :create), passkey: Passkey.generate()

    data = response(conn, 403)
    assert data =~ "Authentication not available."
  end

  test "responds with 403 if underlying passphrase of passkey is invalidated", %{conn: conn} do
    user = Factory.insert(:user)

    passphrase = Factory.insert(:passphrase, user_id: user.id)
    invalidated_passphrase = Factory.insert(:passphrase, user_id: user.id)

    Factory.insert(:passphrase_invalidation,
                   passphrase: passphrase,
                   target_passphrase: invalidated_passphrase)

    conn =
      post conn,
           authentication_token_path(conn, :create),
           passkey: invalidated_passphrase.passkey

    data = response(conn, 403)
    assert data =~ "Authentication not available."
  end

  test "responds with 403 if underlying passphrase of passkey is expired", %{conn: conn} do
    user = Factory.insert(:user)
    passphrase =
      Factory.insert(:passphrase,
                     user: user,
                     inserted_at: NaiveDateTime.from_iso8601!("1970-01-01 00:00:00"))

    conn =
      post conn,
           authentication_token_path(conn, :create),
           passkey: passphrase.passkey

    data = response(conn, 403)
    assert data =~ "Authentication not available."
  end

  test "responds with 403 if user has a newer password reset than recent passphrase", %{conn: conn} do
    user = Factory.insert(:user)
    passphrase = Factory.insert(:passphrase, user: user)
    Factory.insert(:password_reset, user: user)

    conn =
      post conn,
           authentication_token_path(conn, :create),
           passkey: passphrase.passkey

    data = response(conn, 403)
    assert data =~ "Authentication not available."
  end

  test "generates token if the given passphrase is newer than last password reset", %{conn: conn} do
    user = Factory.insert(:user)

    Factory.insert(:password_reset,
                   user: user,
                   inserted_at: NaiveDateTime.from_erl!({{2000, 1, 1}, {13, 30, 15}}))

    passphrase =
      Factory.insert(:passphrase,
                     user: user,
                     inserted_at: NaiveDateTime.from_erl!(:calendar.universal_time()))

    conn =
      post conn,
           authentication_token_path(conn, :create),
           passkey: passphrase.passkey

    data = json_response(conn, 201)["data"]

    assert data["jwt"]
    assert data["exp"]
    assert data["user_id"]
    assert data["timestamp"]
  end
end
