defmodule Spherium.Credentials do
  use Spherium.Web, :virtual

  embedded_schema do
    field :username, :string
    field :password, :string
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:username, min: 4, max: 16)
  end
end
