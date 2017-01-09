defmodule Spherium.Question do
  use Spherium.Web, :model

  schema "questions" do
    belongs_to :publisher, Spherium.Publisher
    belongs_to :user, Spherium.User

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
