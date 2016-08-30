defmodule SpheriumWebService.PublisherControllerTest do
  use SpheriumWebService.ConnCase

  alias SpheriumWebService.Publisher
  @valid_attrs %{description: "some content", image: "some content", name: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, publisher_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    publisher = Repo.insert! %Publisher{}
    conn = get conn, publisher_path(conn, :show, publisher)
    assert json_response(conn, 200)["data"] == %{"id" => publisher.id,
      "user_id" => publisher.user_id,
      "name" => publisher.name,
      "image" => publisher.image,
      "description" => publisher.description}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, publisher_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, publisher_path(conn, :create), publisher: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Publisher, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, publisher_path(conn, :create), publisher: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    publisher = Repo.insert! %Publisher{}
    conn = put conn, publisher_path(conn, :update, publisher), publisher: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Publisher, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    publisher = Repo.insert! %Publisher{}
    conn = put conn, publisher_path(conn, :update, publisher), publisher: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    publisher = Repo.insert! %Publisher{}
    conn = delete conn, publisher_path(conn, :delete, publisher)
    assert response(conn, 204)
    refute Repo.get(Publisher, publisher.id)
  end
end
