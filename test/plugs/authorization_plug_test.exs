defmodule Spherium.AuthorizationPlugTest do
  use Spherium.PlugCase

  alias Spherium.AuthorizationPlug
  alias Spherium.User
  alias Spherium.Factory
  alias Spherium.InsufficientScopeError

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

    assert_raise InsufficientScopeError, fn ->
      Phoenix.ConnTest.build_conn()
      |> put_private(:phoenix_controller, :"Elixir.Spherium.UserController")
      |> put_private(:phoenix_action, :show)
      |> assign(:user, user)
      |> AuthorizationPlug.authorize_user([:all, :self])
    end
  end

  test "policy is not triggered in all permission" do
    user = Repo.get_by!(User, username: "superadmin")

    conn =
      Phoenix.ConnTest.build_conn(:get, "/users/" <> Integer.to_string(user.id))
      |> put_private(:phoenix_controller, :"Elixir.Spherium.UserController")
      |> put_private(:phoenix_action, :show)
      |> assign(:user, user)
      |> fetch_query_params()
      |> AuthorizationPlug.authorize_user([:all, :self])
      |> AuthorizationPlug.apply_policy([])

    refute conn.halted
  end

  test "policy is triggered and passes in self permission" do
    user = Repo.get_by!(User, username: "onesadmin")

    conn =
      Phoenix.ConnTest.build_conn(:get, "/users?username=" <> user.username)
      |> put_private(:phoenix_controller, :"Elixir.Spherium.AttemptController")
      |> put_private(:phoenix_action, :index)
      |> assign(:user, user)
      |> fetch_query_params()
      |> AuthorizationPlug.authorize_user([:all, :self])
      |> AuthorizationPlug.apply_policy([])

    refute conn.halted
  end

  test "policy is triggered and denies in self permission" do
    user = Repo.get_by!(User, username: "onesadmin")
    other_user = Factory.insert(:user)

    assert_raise InsufficientScopeError, fn ->
      Phoenix.ConnTest.build_conn(:get, "/users?username=" <> other_user.username)
      |> put_private(:phoenix_controller, :"Elixir.Spherium.AttemptController")
      |> put_private(:phoenix_action, :index)
      |> assign(:user, user)
      |> fetch_query_params()
      |> AuthorizationPlug.authorize_user([:all, :self])
      |> AuthorizationPlug.apply_policy([])
    end
  end
end
