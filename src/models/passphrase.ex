defmodule Spherium.Passphrase do
  use Spherium.Web, :model

  schema "passphrases" do
    field :passkey, :string
    belongs_to :user, Spherium.User
    field :inserted_at, :naive_datetime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:passkey, :user_id])
    |> validate_required([:passkey, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
