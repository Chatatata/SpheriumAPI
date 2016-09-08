defmodule SpheriumWebService.Credentials do
  use SpheriumWebService.Web, :model

  schema "credentials" do
    field :username, :string
    field :password, :string
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password])   # Fetch with allowed params
    |> validate_required([:username, :password])     # Validate required parameters
  end
end
