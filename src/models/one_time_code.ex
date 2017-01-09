defmodule Spherium.OneTimeCode do
  use Spherium.Web, :model

  @uuid_regex ~r|[0-9,a-z,A-Z]{8}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{12}|

  schema "one_time_codes" do
    belongs_to :user, Spherium.User
    field :code, :integer
    field :device, Ecto.UUID
    field :user_agent, :string
    field :inserted_at, :naive_datetime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :code, :device, :user_agent])
    |> validate_required([:user_id, :code, :device, :user_agent])
    |> validate_format(:device, @uuid_regex)
    |> foreign_key_constraint(:user_id)
  end
end
