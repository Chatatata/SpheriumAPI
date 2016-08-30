defmodule SpheriumWebService.ProfileImageControllerTest do
  use SpheriumWebService.ConnCase

  alias SpheriumWebService.ProfileImage
  @valid_attrs %{data: "some binary data"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "shows chosen resource", %{conn: conn} do
    profile_image = Repo.insert! %ProfileImage{}
    conn = get conn, user_profile_image_path(conn, :show, profile_image)
    assert json_response(conn, 200)["data"] == %{"id" => profile_image.id,
                                                 "user_id" => profile_image.user_id,
                                                 "data" => profile_image.data}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_profile_image_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, user_profile_image_path(conn, :create), profile_image: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(ProfileImage, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_profile_image_path(conn, :create), profile_image: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    profile_image = Repo.insert! %ProfileImage{}
    conn = put conn, user_profile_image_path(conn, :update, profile_image), profile_image: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(ProfileImage, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    profile_image = Repo.insert! %ProfileImage{}
    conn = put conn, user_profile_image_path(conn, :update, profile_image), profile_image: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    profile_image = Repo.insert! %ProfileImage{}
    conn = delete conn, user_profile_image_path(conn, :delete, profile_image)
    assert response(conn, 204)
    refute Repo.get(ProfileImage, profile_image.id)
  end
end
