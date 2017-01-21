defmodule Spherium.CredentialsTest do
  use Spherium.ModelCase

  alias Spherium.Credentials

  test "changeset with valid attributes" do
    changeset =
      Credentials.changeset(%Credentials{},
                            %{username: "some_username",
                              password: "some_password"})

    assert changeset.valid?
  end

  test "changeset without username" do
    changeset =
      Credentials.changeset(%Credentials{},
                            %{password: "some_password"})

    refute changeset.valid?
  end

  test "changeset without password" do
    changeset =
      Credentials.changeset(%Credentials{},
                            %{username: "some_username"})

    refute changeset.valid?
  end

  test "changeset with short username" do
    changeset =
      Credentials.changeset(%Credentials{},
                            %{username: "shr",
                              password: "some_password"})

    refute changeset.valid?
  end

  test "changeset with long username" do
    changeset =
      Credentials.changeset(%Credentials{},
                            %{username: "some_username_longer_than_we_expect",
                              password: "some_password"})

    refute changeset.valid?
  end
end
