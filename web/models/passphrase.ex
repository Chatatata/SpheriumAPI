defmodule Spherium.Passphrase do
  use Spherium.Web, :model

  @uuid_regex ~r|[0-9,a-z,A-Z]{8}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{4}-[0-9,a-z,A-Z]{12}|

  @primary_key {:passkey, :binary_id, autogenerate: true}

  schema "passphrases" do
    belongs_to :user, Spherium.User
    field :device, Ecto.UUID
    field :user_agent, :string
    field :valid?, :boolean
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :device, :user_agent, :valid?])
    |> validate_required([:user_id, :device, :user_agent, :valid?])
    |> validate_format(:device, @uuid_regex)
    |> foreign_key_constraint(:user_id)
  end
end
