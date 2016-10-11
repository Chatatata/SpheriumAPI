defmodule Spherium.Attempt do
  use Spherium.Web, :model

  schema "attempts" do
    field :ip_addr, :string
    field :username, :string
    field :success, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :success, :ip_addr])   # Fetch with allowed params
    |> validate_required([:username, :success, :ip_addr])     # Validate required parameters
  end
end
