defmodule Spherium.PassphraseInvalidationControllerTest do
  use Spherium.ConnCase

  alias Spherium.Factory

  test "invalidates passphrase", %{conn: conn} do
    user = conn.assigns[:setup_user]
    passphrase = Factory.insert(:passphrase, user_id: user.id)

    conn = post conn,
                authentication_passphrase_invalidation_path(
                  conn,
                  :create,
                  passphrase_invalidation: %{target_passphrase_id: passphrase.id}
                )

    assert conn.status == 201
  end

  test "returns 404 when passphrase does not exist", %{conn: conn} do
    assert_error_sent 404, fn ->
      post conn,
           authentication_passphrase_invalidation_path(
             conn,
             :create,
             passphrase_invalidation: %{
               target_passphrase_id: -1
             }
           )
    end
  end

  test "returns 422 when target_passphrase_id is incorrect", %{conn: conn} do
    conn = post conn,
                authentication_passphrase_invalidation_path(
                  conn,
                  :create,
                  passphrase_invalidation: %{target_passphrase_id: nil}
                )

    assert conn.status == 422
  end

  @tag attach_to_one_permissions: true
  test "raises when self user attempts to invalidate others passphrase", %{conn: conn} do
    user = Factory.insert(:user)
    passphrase = Factory.insert(:passphrase, user: user)

    assert_error_sent 401, fn ->
      post conn,
           authentication_passphrase_invalidation_path(
            conn,
            :create,
            passphrase_invalidation: %{
              target_passphrase_id: passphrase.id
            }
           )
    end
  end

  @tag attach_to_one_permissions: true
  test "permits a self user to invalidate own passphrase", %{conn: conn} do
    user = conn.assigns[:setup_user]
    passphrase = Factory.insert(:passphrase, user: user)

    conn = post conn,
           authentication_passphrase_invalidation_path(
            conn,
            :create,
            passphrase_invalidation: %{
              target_passphrase_id: passphrase.id
            }
           )

    assert conn.status == 201
  end
end
