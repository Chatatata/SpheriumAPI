defmodule Spherium.Credentials do
  use Spherium.Web, :model

  @primary_key false

  @uuid_regex ~r([0-9,a-z,A-Z]{8}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{12})

  schema "credentials" do
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
