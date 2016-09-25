defmodule Spherium.AuthenticationServiceTest do
  use Spherium.ServiceCase

  import Plug.Conn, only: [get_resp_header: 2]

  alias Spherium.AuthenticationService
  alias Spherium.User

  test "issues token" do
    user = User.changeset(%User{}, %{username: "test", password: "test", email: "test@mail.com"}) |> Repo.insert!()

    conn = Phoenix.ConnTest.build_conn()
           |> AuthenticationService.issue_token(user)

    assert get_resp_header(conn, "authorization")
    assert get_resp_header(conn, "x-expires")
    assert conn.assigns[:jwt]
    assert conn.assigns[:exp]
  end
end
