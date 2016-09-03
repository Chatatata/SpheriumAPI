defmodule SpheriumWebService.ProfileImage do
  use SpheriumWebService.Web, :model

  schema "profile_images" do
    field :data, :binary
    
    timestamps()
    
    belongs_to :user, SpheriumWebService.User
  end
  
  @allowed_fields ~w(data)a
  @required_fields ~w(data)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @allowed_fields)
    |> validate_required(@required_fields)
  end
end
