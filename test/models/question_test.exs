defmodule Spherium.QuestionTest do
  use Spherium.ModelCase

  alias Spherium.Question

  @user %{id: 5, username: "test", email: "test@mail.com", password: "123456", scope: []}
  @publisher %{id: 10, user_id: @user.id, description: "some content", image: "some content", name: "some content"}
  @valid_attrs %{user_id: @user.id, publisher_id: @publisher.id}

  test "changeset with valid attributes" do
    changeset = Question.changeset(%Question{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with missing publisher" do
    changeset = Question.changeset(%Question{}, %{user_id: @user.id})
    refute changeset.valid?
  end
  
  test "changeset with missing user" do
    changeset = Question.changeset(%Question{}, %{publisher_id: @publisher.id})
    refute changeset.valid?
  end
end
