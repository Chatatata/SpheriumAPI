defmodule Spherium.UserTest do
  use Spherium.ModelCase
  
  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias Spherium.User

  @valid_attrs %{username: "test", email: "test@mail.com", password: "123456", scope: []}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end
  
  test "changeset with short name" do
    changeset = User.changeset(%User{}, %{username: "aaa", email: "test@mail.com", password: "123456", scope: []})
    refute changeset.valid?
  end
  
  test "changeset with long name" do
    changeset = User.changeset(%User{}, %{username: "a_name_which_is_very_long", email: "test@mail.com", password: "123456", scope: []})
    refute changeset.valid?
  end
  
  test "changeset with invalid email" do
    changeset = User.changeset(%User{}, %{username: "test", email: "testmail.com", password: "123456", scope: []})
    refute changeset.valid?
  end
  
  test "password_digest gets set to hash" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert checkpw(get_field(changeset, :password), get_change(changeset, :password_digest))
  end
  
  test "password_digest does not get set if password is nil" do
    changeset = User.changeset(%User{}, %{username: "test", email: "test@mail.com"})
    refute get_change(changeset, :password_digest)
  end
end
