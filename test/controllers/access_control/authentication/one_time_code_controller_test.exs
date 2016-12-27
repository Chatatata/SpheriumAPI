defmodule Spherium.OneTimeCodeControllerTest do
  use Spherium.ConnCase

  alias Spherium.Factory

  @tag super_cow_powers: false

  test "generates an OTC to the user", %{conn: conn} do
    user = Factory.insert(:user, password: "123456")

    conn = post conn,
                one_time_code_path(conn, :create),
                credentials: %{
                  username: user.username,
                  password: "123456",
                  device: Ecto.UUID.generate(),
                  user_agent: "Test user agent"
                }

    assert json_response(conn, 201)["user_id"] == user.id
  end
end
