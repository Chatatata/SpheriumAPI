defmodule SpheriumWebService.SubscriberControllerTest do
  use SpheriumWebService.ConnCase

  alias SpheriumWebService.Subscriber
  @valid_attrs %{address: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, subscriber_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    subscriber = Repo.insert! %Subscriber{}
    conn = get conn, subscriber_path(conn, :show, subscriber)
    assert json_response(conn, 200)["data"] == %{"id" => subscriber.id,
      "address" => subscriber.address}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, subscriber_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, subscriber_path(conn, :create), subscriber: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Subscriber, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, subscriber_path(conn, :create), subscriber: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    subscriber = Repo.insert! %Subscriber{}
    conn = put conn, subscriber_path(conn, :update, subscriber), subscriber: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Subscriber, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    subscriber = Repo.insert! %Subscriber{}
    conn = put conn, subscriber_path(conn, :update, subscriber), subscriber: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    subscriber = Repo.insert! %Subscriber{}
    conn = delete conn, subscriber_path(conn, :delete, subscriber)
    assert response(conn, 204)
    refute Repo.get(Subscriber, subscriber.id)
  end
end
