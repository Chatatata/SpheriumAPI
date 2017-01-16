defmodule Spherium.PassphraseControllerTest do
  use Spherium.ConnCase

  alias Spherium.Factory

  @tag super_cow_powers: false

  test "creates a new passphrase with valid one time code", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")
    otc = Factory.insert(:one_time_code, user: user)

    conn = post conn,
                authentication_passphrase_path(conn, :create),
                passphrase_generation_attempt: %{code: otc.code,
                                                 user_id: user.id}

    data = json_response(conn, 201)["data"]

    assert data
    assert data["passkey"]
    assert data["passphrase_id"]
  end

  test "does not create a passphrase with expired one time code", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")
    otc = Factory.insert(:one_time_code,
                         user: user,
                         inserted_at: NaiveDateTime.from_erl!({{2000, 1, 1}, {13, 30, 15}}))

    conn = post conn,
                authentication_passphrase_path(conn, :create),
                passphrase_generation_attempt: %{code: otc.code,
                                                 user_id: user.id}

    assert text_response(conn, 404) =~ "Pair not found."
  end

  test "does not create a passphrase with no one time code generated", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")

    conn = post conn,
                authentication_passphrase_path(conn, :create),
                passphrase_generation_attempt: %{code: 123456,
                                                 user_id: user.id}

    assert text_response(conn, 404) =~ "Pair not found."
  end

  test "rejects request if given code is invalid", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")
    _otc = Factory.insert(:one_time_code,
                          user: user,
                          inserted_at: NaiveDateTime.from_erl!({{2000, 1, 1}, {13, 30, 15}}))

    conn = post conn,
                authentication_passphrase_path(conn, :create),
                passphrase_generation_attempt: %{code: 1000000,
                                                 user_id: user.id}

    assert conn.status == 422
  end

  test "rejects request if given code does not match", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")
    _otc = Factory.insert(:one_time_code,
                          user: user)

    conn = post conn,
                authentication_passphrase_path(conn, :create),
                passphrase_generation_attempt: %{code: 100001,
                                                 user_id: user.id}

    assert text_response(conn, 404) =~ "Pair not found."
  end

  test "checks for already satisfied one time code", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")
    otc = Factory.insert(:one_time_code,
                         user: user)
    _passphrase = Factory.insert(:passphrase,
                                 one_time_code: otc)

    conn = post conn,
                authentication_passphrase_path(conn, :create),
                passphrase_generation_attempt: %{code: otc.code,
                                                 user_id: user.id}

    assert text_response(conn, 404) =~ "Pair not found."
  end

  test "checks for already invalidated one time code", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")
    otc = Factory.insert(:one_time_code,
                         user: user)
    Factory.insert(:one_time_code_invalidation, one_time_code_id: otc.id)

    conn = post conn,
                authentication_passphrase_path(conn, :create),
                passphrase_generation_attempt: %{code: otc.code,
                                                 user_id: user.id}

    assert text_response(conn, 404) =~ "Pair not found."
  end
end
