defmodule Spherium.AuthenticationServiceTest do
  use Spherium.ServiceCase

  import Plug.Conn, only: [get_resp_header: 2]

  alias Spherium.AuthenticationService
  alias Spherium.User
  alias Spherium.Factory

  @tag super_cow_powers: false

  test "issues token" do
    user = User.changeset(%User{}, %{username: "test", password: "test", email: "test@mail.com"}) |> Repo.insert!()
    passphrase = Factory.insert(:passphrase, user_id: user.id)

    conn =
      Phoenix.ConnTest.build_conn()
      |> AuthenticationService.issue_token(user, passphrase)

    assert get_resp_header(conn, "authorization")
    assert get_resp_header(conn, "x-expires")
    assert conn.assigns[:jwt]
    assert conn.assigns[:exp]
  end
end
