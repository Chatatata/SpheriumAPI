defmodule Spherium.PasswordResetTest do
  use Spherium.ModelCase

  alias Spherium.PasswordReset
  alias Spherium.Factory

  test "changeset with valid attributes" do
    user = Factory.insert(:user)

    changeset = PasswordReset.changeset(%PasswordReset{}, %{user_id: user.id})

    assert changeset.valid?
  end
end
