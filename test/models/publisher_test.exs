defmodule SpheriumWebService.PublisherTest do
  use SpheriumWebService.ModelCase

  alias SpheriumWebService.Publisher

  @user %{id: 5, username: "test", email: "test@mail.com", password: "123456", scope: []}
  @valid_attrs %{user_id: @user.id, description: "some content", image: "some content", name: "some content"}

  test "changeset with valid attributes" do
    changeset = Publisher.changeset(%Publisher{}, @valid_attrs)
    IO.inspect changeset.errors
    assert changeset.valid?
  end
  
  test "changeset with missing user assoc" do
    changeset = Publisher.changeset(%Publisher{}, %{description: "some content", image: "some content", name: "some content"})
    refute changeset.valid?
  end

  test "changeset with missing name" do
    changeset = Publisher.changeset(%Publisher{}, %{user_id: @user.id, description: "some content", image: "some content"})
    refute changeset.valid?
  end
end
