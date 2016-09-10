defmodule SpheriumWebService.UserControllerTest do
  use SpheriumWebService.ConnCase

  alias SpheriumWebService.User
  alias SpheriumWebService.UserView
  alias SpheriumWebService.Factory

  @valid_create_attrs %{username: "another_test", email: "another_test@mail.com", password: "123456", scope: []}
  @valid_attrs %{username: "another_test", email: "another_test@mail.com"}
  @invalid_attrs %{email: "test mail.com"}

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)

    assert for {key, val} <- json_response(conn, 200)["data"], into: %{}, do: {String.to_atom(key), val} == Phoenix.View.render_many(Repo.all(User), UserView, "user.json")
  end

  test "shows chosen resource", %{conn: conn} do
    user = Factory.insert(:user)                      # Insert a user to the database
    conn = get conn, user_path(conn, :show, user)     # Make a GET request with that users identifier

    data = json_response(conn, 200)["data"]

    assert user.id == data["id"] and user.email == data["email"]
    refute data["activation_key"]
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_create_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not create resource and renders errors when username already exists", %{conn: conn} do
    user = Factory.insert(:user)
    conn = post conn, user_path(conn, :create), user: %{username: user.username, email: "another_test@mail.com", password: "123456", scope: []}

    assert json_response(conn, 422)["errors"]["username"] == ["has already been taken"]
  end

  test "does not create resource and renders errors when email already exists", %{conn: conn} do
    user = Factory.insert(:user)
    conn = post conn, user_path(conn, :create), user: %{username: "another_test", email: user.email, password: "123456", scope: []}

    assert json_response(conn, 422)["errors"]["email"] == ["has already been taken"]
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user = Factory.insert(:user)
    conn = put conn, user_path(conn, :update, user), user: @valid_create_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Factory.insert(:user)
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not update resource when there is no resource with given identifier", %{conn: conn} do
    assert_error_sent 404, fn ->
      put conn, user_path(conn, :update, -1), user: @valid_create_attrs
    end
  end

  test "deletes chosen resource", %{conn: conn} do
    user = Factory.insert(:user)
    conn = delete conn, user_path(conn, :delete, user)
    assert response(conn, 204)
    refute Repo.get(User, user.id)
  end

  test "does not delete resource when there is no resource with given identifier", %{conn: conn} do
    assert_error_sent 404, fn ->
      delete conn, user_path(conn, :update, -1)
    end
  end
end
