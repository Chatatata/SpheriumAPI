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
  
  @allowed_fields ~w(name image description user_id)a
  @required_fields ~w(name user_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @allowed_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
  end
end
