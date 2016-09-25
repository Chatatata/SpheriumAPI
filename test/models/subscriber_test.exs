defmodule Spherium.SubscriberTest do
  use Spherium.ModelCase

  alias Spherium.Subscriber

  @valid_attrs %{address: "test@mail.com"}

  test "changeset with valid email address" do
    changeset = Subscriber.changeset(%Subscriber{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid email address" do
    changeset = Subscriber.changeset(%Subscriber{}, %{address: "invalidmail"})
    refute changeset.valid?
  end
  
  test "changeset with blank email address" do
    changeset = Subscriber.changeset(%Subscriber{}, %{address: ""})
    refute changeset.valid?
  end
end
