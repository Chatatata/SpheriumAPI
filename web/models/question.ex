defmodule SpheriumWebService.Question do
  use SpheriumWebService.Web, :model

  schema "questions" do
    belongs_to :publisher, SpheriumWebService.Publisher
    belongs_to :user, SpheriumWebService.User

    timestamps()
  end
  
  @allowed_fields ~w()a
  @required_fields ~w()a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @allowed_fields)
    |> cast_assoc(:publisher, required: true)
    |> cast_assoc(:user, required: true)
    |> validate_required(@required_fields)
  end
end
