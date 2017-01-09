defmodule Spherium.Credentials do
  use Spherium.Web, :model

  @uuid_regex ~r([0-9,a-z,A-Z]{8}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{12})

  schema "credentials" do
    field :username, :string
    field :password, :string
    field :device, :string
    field :user_agent, :string
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password, :device, :user_agent])
    |> validate_required([:username, :password, :device, :user_agent])
    |> validate_format(:device, @uuid_regex)
  end
end
