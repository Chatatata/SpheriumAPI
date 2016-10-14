defmodule Spherium.AuthenticationTest do
  use Spherium.PlugCase

  alias Spherium.AuthenticationPlug
  alias Spherium.AuthHelper
  alias Spherium.User
  alias Spherium.Factory

  @tag super_cow_powers: false

  test "authenticates user with valid token" do
    user = User.changeset(%User{}, %{username: "test", password: "test", email: "test@mail.com"}) |> Repo.insert!()
    passphrase = Factory.insert(:passphrase, user: user)

    conn = Phoenix.ConnTest.build_conn()
           |> AuthHelper.issue_token(user, passphrase)
           |> AuthenticationPlug.authenticate_user(nil)

    assigned = conn.assigns[:user]

    assert assigned.username == "test"
    refute assigned.password_digest == "test"
    assert assigned.email == "test@mail.com"
    assert assigned.id
  end

  test "does not authenticate user with invalid token" do
    conn = Phoenix.ConnTest.build_conn()
           |> Plug.Conn.put_req_header("authorization", "Bearer maliciously.generated.token")
           |> AuthenticationPlug.authenticate_user(nil)

    refute conn.assigns[:user]
    assert conn.halted
    assert conn.status == 403
  end

  test "does not authenticate user with invalid authorization header" do
    conn = Phoenix.ConnTest.build_conn()
           |> Plug.Conn.put_req_header("authorization", "maliciously.generated.token")
           |> AuthenticationPlug.authenticate_user(nil)

    refute conn.assigns[:user]
    assert conn.halted
    assert conn.status == 403
  end

  test "does not authenticate user without token" do
    conn = Phoenix.ConnTest.build_conn()
           |> AuthenticationPlug.authenticate_user(nil)

    refute conn.assigns[:user]
    assert conn.halted
    assert conn.status == 403
  end
end
