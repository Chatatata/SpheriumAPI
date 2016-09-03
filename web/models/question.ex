defmodule SpheriumWebService.Question do
  use SpheriumWebService.Web, :model

  schema "questions" do
    belongs_to :publisher, SpheriumWebService.Publisher
    belongs_to :user, SpheriumWebService.User

    timestamps()
  end
  
  @allowed_fields ~w(publisher_id user_id)a
  @required_fields ~w(publisher_id user_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @allowed_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:publisher_id)
    |> foreign_key_constraint(:user_id)
  end
end
