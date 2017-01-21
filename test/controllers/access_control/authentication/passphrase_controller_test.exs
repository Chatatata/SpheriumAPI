defmodule Spherium.PassphraseControllerTest do
  use Spherium.ConnCase

  alias Spherium.Factory

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, authentication_passphrase_path(conn, :index)

    data = json_response(conn, 200)["data"]

    assert Enum.count(data) == 2

    Enum.each(data, fn(element) ->
      assert element["id"]
      assert element["user_id"]
      assert element["user_agent"]
      assert element["device"]
      assert element["inserted_at"]
    end)
  end

  test "shows chosen resource", %{conn: conn} do
    user = Factory.insert(:user)
    passphrase = Factory.insert(:passphrase, user_id: user.id)

    conn = get conn, authentication_passphrase_path(conn, :show, passphrase)

    data = json_response(conn, 200)["data"]

    assert data
    assert data["id"] == passphrase.id
    assert data["user_id"] == passphrase.user_id
    assert data["device"] =~ passphrase.device
    assert data["user_agent"] =~ passphrase.user_agent
    assert data["inserted_at"]
    refute data["passkey"]
  end
end
