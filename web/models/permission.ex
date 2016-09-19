defmodule SpheriumWebService.Permission do
  @moduledoc """
  Defines a permission.

  Permission is an abstract model, which may inherited by different types of
  permissions. Therefore, the model itself does not define a valid permission.

  Permissions determine the user accessibility on some kind of operation.
  Suppose you want to authorize a user to revoke an action in web server,
  to do such thing, user should have a valid permission set with required
  permissions attached.

  ## Grant powers

  Permissions also have a `:required_grant_power` property, which determines
  the required minimum grant power in terms of possessibility by a permission
  set. A permission with `x` required grant power could be possessed by a
  permission set with `y` grant power if and only if `x ≤ y`.

  ## Immutability and determinism

  Permissions are immutable, and its types have deterministic sizes. There
  could not be infinite amount of possible permissions in some kind.
  Permissions could be nil-bound, however they are not garbage collected
  (i.e. vacuumed).
  """
  use SpheriumWebService.Web, :model

  schema "permissions" do
    field :required_grant_power, :integer
    field :controller_name, :string
    field :controller_action, :string
    field :type, :string

    many_to_many :permission_sets, SpheriumWebService.PermissionSet, join_through: "permission_set_permissions"
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:required_grant_power, :controller_name, :controller_action, :type])
    |> validate_required([:required_grant_power])
    |> validate_inclusion(:required_grant_power, 0..999)
    |> validate_required([:controller_name, :controller_action, :type])
    |> validate_inclusion(:type, ["none", "one", "all"])
    |> validate_length(:controller_name, max: 100)
    |> validate_length(:controller_action, max: 30)
    |> unique_constraint(:controller_name, name: :controller_access_permissions_unique_couple)
  end
end
