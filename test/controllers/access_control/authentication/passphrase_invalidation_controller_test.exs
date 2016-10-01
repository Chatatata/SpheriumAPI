defmodule Spherium.PassphraseInvalidationControllerTest do
  use Spherium.ConnCase

  alias Spherium.Passphrase
  alias Spherium.Factory

  test "invalidates passphrase", %{conn: conn} do
    user = Factory.insert(:user)
    passphrase = Factory.insert(:passphrase, user_id: user.id)

    conn = post conn, passphrase_passphrase_invalidation_path(conn, :create, passphrase.passkey)

    assert conn.status == 201
    assert Repo.get_by(Passphrase, %{passkey: passphrase.passkey, valid?: false})
  end

  test "returns 404 when passphrase does not exist", %{conn: conn} do
    conn = post conn, passphrase_passphrase_invalidation_path(conn, :create, Ecto.UUID.generate())

    assert conn.status == 404
  end
end
