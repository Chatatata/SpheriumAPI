defmodule Spherium.PermissionSetGrantTest do
  use Spherium.ModelCase

  alias Spherium.PermissionSetGrant
  alias Spherium.Factory

  test "changeset with valid attributes" do
    permission_set_owner = Factory.insert(:user)
    permission_set = Factory.insert(:permission_set, user_id: permission_set_owner.id)
    user = Factory.insert(:user)
    target_user = Factory.insert(:user)

    changeset = PermissionSetGrant.changeset(%PermissionSetGrant{}, %{permission_set_id: permission_set.id, user_id: user.id, target_user_id: target_user.id})

    assert changeset.valid?
  end

  test "changeset without user id" do
    permission_set_owner = Factory.insert(:user)
    permission_set = Factory.insert(:permission_set, user_id: permission_set_owner.id)
    target_user = Factory.insert(:user)

    changeset = PermissionSetGrant.changeset(%PermissionSetGrant{}, %{permission_set_id: permission_set.id, user_id: nil, target_user_id: target_user.id})

    refute changeset.valid?
  end

  test "changeset without target user id" do
    permission_set_owner = Factory.insert(:user)
    permission_set = Factory.insert(:permission_set, user_id: permission_set_owner.id)
    user = Factory.insert(:user)

    changeset = PermissionSetGrant.changeset(%PermissionSetGrant{}, %{permission_set_id: permission_set.id, user_id: user.id, target_user_id: nil})

    refute changeset.valid?
  end
  
  test "changeset without permission set" do
    user = Factory.insert(:user)
    target_user = Factory.insert(:user)

    changeset = PermissionSetGrant.changeset(%PermissionSetGrant{}, %{permission_set_id: nil, user_id: user.id, target_user_id: target_user.id})

    refute changeset.valid?
  end
end
