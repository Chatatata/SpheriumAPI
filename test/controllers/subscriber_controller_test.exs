defmodule SpheriumWebService.SubscriberControllerTest do
  use SpheriumWebService.ConnCase

  alias SpheriumWebService.Subscriber
  alias SpheriumWebService.Factory
  
  @valid_attrs %{address: "some@content.com"}
  @invalid_attrs %{address: "some content"}

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, subscriber_path(conn, :index)
    
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    subscriber = Factory.insert(:subscriber)
    conn = get conn, subscriber_path(conn, :show, subscriber)
    
    data = json_response(conn, 200)["data"]
    
    assert data["id"]
    assert subscriber.address == data["address"]
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, subscriber_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, subscriber_path(conn, :create), subscriber: @valid_attrs
    
    data = json_response(conn, 201)["data"]
    
    assert data["id"]
    assert Repo.get_by(Subscriber, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, subscriber_path(conn, :create), subscriber: @invalid_attrs
    
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    subscriber = Factory.insert(:subscriber)
    conn = put conn, subscriber_path(conn, :update, subscriber), subscriber: @valid_attrs
    
    data =  json_response(conn, 200)["data"]
    
    assert data["id"]
    assert Repo.get_by(Subscriber, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    subscriber = Factory.insert(:subscriber)
    conn = put conn, subscriber_path(conn, :update, subscriber), subscriber: @invalid_attrs
    
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    subscriber = Factory.insert(:subscriber)
    conn = delete conn, subscriber_path(conn, :delete, subscriber)
    
    assert response(conn, 204)
    refute Repo.get(Subscriber, subscriber.id)
  end
end
