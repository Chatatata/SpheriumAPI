defmodule SpheriumWebService.ProfileImageTest do
  use SpheriumWebService.ModelCase

  alias SpheriumWebService.ProfileImage

  @valid_attrs %{user: %{id: 5, username: "test", email: "test@mail.com", password: "123456", scope: []}, data: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ProfileImage.changeset(%ProfileImage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ProfileImage.changeset(%ProfileImage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
