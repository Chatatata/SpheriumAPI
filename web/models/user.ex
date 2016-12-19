defmodule Spherium.User do
  use Spherium.Web, :model

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :username, :string
    field :email, :string
    field :password_digest, :string
    field :activation_key, Ecto.UUID
    field :activation_date, Ecto.DateTime

    field :password, :string, virtual: true

    timestamps

    has_one :image, Spherium.ProfileImage
    has_many :publishers, Spherium.Publisher
    belongs_to :permission_set, Spherium.PermissionSet
  end

  @email_regex ~r/(\w+)@([\w.]+)/

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:username, :email, :password_digest, :password]) # Cast with allowed fields to changeset
    |> hash_password() # Hash password if changed
    |> validate_required([:username, :email, :password_digest]) # Validate the required fields
    |> validate_length(:username, min: 4, max: 16) # Username should be 5-16 characters long
    |> validate_format(:email, @email_regex) # Validate email
    |> unique_constraint(:username) # Username should be unique
    |> unique_constraint(:email) # Email should be unique
    |> foreign_key_constraint(:permission_set_id)
  end

  def permissions_set_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:permission_set_id])
    |> foreign_key_constraint(:permission_set_id)
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      changeset
      |> put_change(:password_digest, hashpwsalt(password))
    else
      changeset
    end
  end
end
