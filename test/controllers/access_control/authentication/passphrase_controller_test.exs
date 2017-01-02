defmodule Spherium.PassphraseControllerTest do
  use Spherium.ConnCase

  alias Spherium.Passphrase
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
end
