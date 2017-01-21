defmodule Spherium.DeviceInformation do
  use Spherium.Web, :virtual

  @uuid_regex ~r([0-9,a-z,A-Z]{8}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{12})

  embedded_schema do
    field :device, Ecto.UUID
    field :user_agent, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:device, :user_agent])
    |> validate_required([:device, :user_agent])
    |> validate_format(:device, @uuid_regex)
  end
end
