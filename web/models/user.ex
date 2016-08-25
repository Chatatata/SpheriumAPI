defmodule SpheriumWebService.User do
  use SpheriumWebService.Web, :model
  
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :username, :string
    field :email, :string
	  field :password_digest, :string
    field :scope, {:array, :string}
    field :activation_key, :uuid
	  field :activation_date, :datetime
	
	  field :password, :string, virtual: true

    timestamps
  end

  @allowed_fields ~w(username email password scope)
  @required_fields ~w(username email password)
  @optional_fields ~w(scope)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @allowed_fields)						      # Cast with allowed fields to changeset
	  |> validate_required(@required_fields)					  # Validate the required fields
	  |> validate_length(:username, min: 4, max: 16)		# Username should be 5-16 characters long
	  |> hash_password
    |> unique_constraint(:username)							      # Username should be unique
	  |> unique_constraint(:email)							        # Email should be unique
  end
  
  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      changeset
      |> put_change(:password, hashpwsalt(password))
    else
      changeset
    end
  end
end
