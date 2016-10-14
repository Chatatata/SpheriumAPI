defmodule Spherium.AuthorizationPlugTest do
  use Spherium.PlugCase

  alias Spherium.AuthorizationPlug
  alias Spherium.User
  alias Spherium.Factory

  test "accepts a user with non-selective permission" do
    user = Repo.get_by!(User, username: "superadmin")

    conn =
      Phoenix.ConnTest.build_conn()
      |> put_private(:phoenix_controller, :"Elixir.Spherium.UserController")
      |> put_private(:phoenix_action, :index)
      |> assign(:user, user)
      |> AuthorizationPlug.authorize_user([:all, :self])

    assert conn.assigns[:permission_type]
    refute conn.halted
  end

  test "accepts a user with selective permission" do
    user = Repo.get_by!(User, username: "onesadmin")

    conn =
      Phoenix.ConnTest.build_conn()
      |> put_private(:phoenix_controller, :"Elixir.Spherium.UserController")
      |> put_private(:phoenix_action, :show)
      |> assign(:user, user)
      |> AuthorizationPlug.authorize_user([:all, :self])

    assert conn.assigns[:permission_type]
    refute conn.halted
  end

  test "refutes a user without permission" do
    user = Factory.insert(:user)

    conn =
      Phoenix.ConnTest.build_conn()
      |> put_private(:phoenix_controller, :"Elixir.Spherium.UserController")
      |> put_private(:phoenix_action, :show)
      |> assign(:user, user)
      |> AuthorizationPlug.authorize_user([:all, :self])

    refute conn.assigns[:permission_type]
    assert conn.halted
    assert conn.status == 401
  end
end
