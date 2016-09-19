defmodule SpheriumWebService.PermissionSetGrant do
  @moduledoc """
  Defines a permission set grant applied on a user.

  ## Permission grants

  When a permission set of a user is going to be changed, permission set grants
  are used. Upon creation of a new valid permission set grant, the underlying
  user is granted by the given permission set. Permission set
  grants is a model representing verbose logging of permission set changes of
  users. Permission set grants made available automatically by application
  (i.e. grant upon activation) does not get represented by a permission set
  grant. These grants should be in a deterministic way, hence it will not
  break consistency of the permission set grants, permission set grants
  should represent the correct changes of users permission set.

  An illustration of this situation could be user activations. User activations
  modify permission sets of users, however, in a query which finds the last
  created permission set affecting some target user, should give the current
  permission set of that user.

  Permission set grants represent valid permission set grant attempts,
  which means an invalid permission set grant attempt (typically made by a user
  who is insufficient to grant subject permission) without visible effect on
  target user's permission set is not get persisted.
  """
  use SpheriumWebService.Web, :model

  schema "permission_set_grants" do
    belongs_to :permission_set, SpheriumWebService.PermissionSet
    belongs_to :user, SpheriumWebService.User
    belongs_to :target_user, SpheriumWebService.User
    field :inserted_at, Ecto.DateTime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:permission_set_id, :user_id, :target_user_id])
    |> validate_required([:permission_set_id, :user_id, :target_user_id])
    |> foreign_key_constraint(:user)
    |> foreign_key_constraint(:target_user)
  end
end
