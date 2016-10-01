defmodule Spherium.TokenControllerTest do
  use Spherium.ConnCase

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

  test "throws 404 if passkey does not exist", %{conn: conn} do
    assert_error_sent 404, fn ->
      post conn, token_path(conn, :create), passkey: Ecto.UUID.generate()
    end
  end
end
