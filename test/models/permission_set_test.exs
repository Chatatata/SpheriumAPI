defmodule Spherium.PermissionSetTest do
  use Spherium.ModelCase

  alias Spherium.PermissionSet
  alias Spherium.Factory

  test "changeset with permission identifiers" do
    user = Factory.insert(:user)
    permission = Factory.insert(:permission)

    changeset = PermissionSet.changeset(%PermissionSet{}, %{name: "some",
                                                            description: "Nice permission set.",
                                                            grant_power: 500,
                                                            user_id: user.id,
                                                            permission_ids: [permission.id]})

    assert changeset.valid?
    assert get_field(changeset, :permissions) == [permission]
  end

  test "changeset with nil permission identifiers" do
    user = Factory.insert(:user)
    changeset = PermissionSet.changeset(%PermissionSet{}, %{name: "some",
                                                            description: "Nice permission set.",
                                                            grant_power: 500,
                                                            user_id: user.id,
                                                            permission_ids: nil})

    refute changeset.valid?
  end

  test "changeset with insparse permission identifier array" do
    user = Factory.insert(:user)
    permission = Factory.insert(:permission)
    changeset = PermissionSet.changeset(%PermissionSet{}, %{name: "some",
                                                            description: "Nice permission set.",
                                                            grant_power: 500,
                                                            user_id: user.id,
                                                            permission_ids: [permission.id, permission.id]})

    refute changeset.valid?
  end

  test "changeset with exceeding grant power" do
    user = Factory.insert(:user)
    changeset = PermissionSet.changeset(%PermissionSet{}, %{name: "some",
                                                            description: "Nice permission set.",
                                                            grant_power: 1001,
                                                            user_id: user.id,
                                                            permission_ids: []})

    refute changeset.valid?
  end

  test "changeset with negative grant power" do
    user = Factory.insert(:user)
    changeset = PermissionSet.changeset(%PermissionSet{}, %{name: "some",
                                                            description: "Nice permission set.",
                                                            grant_power: -500,
                                                            user_id: user.id,
                                                            permission_ids: []})

    refute changeset.valid?
  end

  test "changeset with invalid permission identifiers" do
    user = Factory.insert(:user)
    changeset = PermissionSet.changeset(%PermissionSet{}, %{name: "some",
                                                            description: "Nice permission set.",
                                                            grant_power: 500,
                                                            user_id: user.id,
                                                            permission_ids: [-1]})

    refute changeset.valid?
  end
end
