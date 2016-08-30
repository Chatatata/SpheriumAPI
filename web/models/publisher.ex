defmodule SpheriumWebService.Publisher do
  use SpheriumWebService.Web, :model

  schema "publishers" do
    field :name, :string
    field :image, :binary
    field :description, :string
    
    belongs_to :user, SpheriumWebService.User
    has_many :questions, SpheriumWebService.Question

    timestamps()
  end
  
  @allowed_fields ~w(name image description)a
  @required_fields ~w(name)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @allowed_fields)
    |> cast_assoc(:user, required: true)
    |> validate_required(@required_fields)
  end
end
