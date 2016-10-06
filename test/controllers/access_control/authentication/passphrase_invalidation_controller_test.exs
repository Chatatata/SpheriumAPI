defmodule Spherium.PassphraseInvalidationControllerTest do
  use Spherium.ConnCase

  alias Spherium.Factory

  test "invalidates passphrase", %{conn: conn} do
    user = conn.assigns[:setup_user]
    passphrase = Factory.insert(:passphrase, user_id: user.id)

    conn = post conn, passphrase_invalidation_path(conn, :create, passphrase_invalidation: %{target_passphrase_id: passphrase.id})

    assert conn.status == 201
  end

  test "returns 404 when passphrase does not exist", %{conn: conn} do
    conn = post conn, passphrase_invalidation_path(conn, :create, passphrase_invalidation: %{target_passphrase_id: -1})

    assert conn.status == 404
  end

  test "returns 422 when target_passphrase_id is incorrect", %{conn: conn} do
    conn = post conn, passphrase_invalidation_path(conn, :create, passphrase_invalidation: %{target_passphrase_id: nil})

    assert conn.status == 422
  end
end
