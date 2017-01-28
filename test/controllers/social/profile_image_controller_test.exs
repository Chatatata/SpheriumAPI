defmodule Spherium.ProfileImageControllerTest do
  use Spherium.ConnCase

  alias Spherium.ProfileImage
  alias Spherium.Factory

  @valid_attrs %{data: "some binary data"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "shows chosen resource", %{conn: conn} do
    image = Factory.insert(:profile_image)
    conn = get conn, user_profile_image_path(conn, :show, image.user)

    data = json_response(conn, 200)["data"]

    assert data["data"]
  end

  test "throws 404 if given user does not exist", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_profile_image_path(conn, :update, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    user = Factory.insert(:user)
    conn = post conn, user_profile_image_path(conn, :create, user), profile_image: @valid_attrs

    data = json_response(conn, 201)["data"]

    assert data["id"]
    assert Repo.get_by(ProfileImage, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    user = Factory.insert(:user)
    conn = post conn, user_profile_image_path(conn, :create, user), profile_image: @invalid_attrs

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    profile_image = Factory.insert(:profile_image)
    conn = put conn, user_profile_image_path(conn, :update, profile_image.user), profile_image: Map.merge(@valid_attrs, %{user: Map.from_struct(profile_image.user)})

    data = json_response(conn, 200)["data"]

    assert data["id"]
    assert Repo.get_by(ProfileImage, @valid_attrs)
  end

  test "returns 422 if given data is invalid to update", %{conn: conn} do
    profile_image = Factory.insert(:profile_image)

    conn = put conn,
               user_profile_image_path(conn, :update, profile_image.user),
               profile_image: %{data: nil}

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "throws 404 if given user does not exist to update", %{conn: conn} do
    assert_error_sent 404, fn ->
      put conn, user_profile_image_path(conn, :update, -1), profile_image: @valid_attrs
    end
  end

  test "deletes chosen resource", %{conn: conn} do
    profile_image = Factory.insert(:profile_image)
    conn = delete conn, user_profile_image_path(conn, :delete, profile_image.user)

    assert response(conn, 204)
    refute Repo.get(ProfileImage, profile_image.id)
  end
end
