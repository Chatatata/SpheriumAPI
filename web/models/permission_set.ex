defmodule Spherium.PermissionSet do
  @moduledoc """
  Defines a permission set.

  A permission set holds a set of permissions that can be used to
  authorize the requests. A user cannot be binded to permissions directly,
  instead it has a permission set which defines the broadness of user
  accessibility.

  ## Grant powers

  Permission sets are also capable of determination of creating new
  permissions with their grant power property. A user with a higher
  permission set may grant new permissions to other users as long as
  that permissions' required grant powers are lower than the one in the user.

  See `Spherium.Permission` for more information about permission
  granting.
  """
  use Spherium.Web, :model

  import Ecto.Query, only: [where: 3]

  alias Spherium.Repo
  alias Spherium.Permission

  schema "permission_sets" do
    field :name, :string
    field :description, :string
    field :grant_power, :integer
    belongs_to :user, Spherium.User
    field :inserted_at, Ecto.DateTime

    has_many :users, Spherium.User
    many_to_many :permissions, Spherium.Permission, join_through: "permission_set_permissions"
    field :permission_ids, {:array, :integer}, virtual: true
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :grant_power, :user_id, :permission_ids])
    |> validate_required([:name, :description, :grant_power, :user_id, :permission_ids])
    |> validate_inclusion(:grant_power, 0..999)
    |> foreign_key_constraint(:user_id)
    |> put_permission_assoc()
  end

  defp put_permission_assoc(changeset) do
    if permission_ids = get_change(changeset, :permission_ids) do
      permissions = Permission
                    |> where([p], p.id in ^Enum.uniq(permission_ids))
                    |> Repo.all()

      if Enum.count(permissions) == Enum.count(permission_ids) and
         Enum.count(permissions) != 0,
        do: put_assoc(changeset, :permissions, permissions),
        else: add_error(changeset, :permission_ids, "is empty or not sparse")
    else
      changeset
    end
  end
end
