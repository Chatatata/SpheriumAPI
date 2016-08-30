defmodule SpheriumWebService.QuestionTest do
  use SpheriumWebService.ModelCase

  alias SpheriumWebService.Question

  @user %{id: 5, username: "test", email: "test@mail.com", password: "123456", scope: []}
  @publisher %{user: @user, description: "some content", image: "some content", name: "some content"}
  @valid_attrs %{user: @user, publisher: @publisher}

  test "changeset with valid attributes" do
    changeset = Question.changeset(%Question{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with missing publisher" do
    changeset = Question.changeset(%Question{}, %{user: @user})
    refute changeset.valid?
  end
end
