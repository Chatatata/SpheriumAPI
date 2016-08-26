defmodule SpheriumWebService.Subscriber do
  use SpheriumWebService.Web, :model

  schema "subscribers" do
    field :address, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:address])
    |> validate_required([:address])
  end
end
