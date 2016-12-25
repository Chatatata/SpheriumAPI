defmodule Spherium.Passphrase do
  use Spherium.Web, :model

  schema "passphrases" do
    field :passkey, :string
    belongs_to :one_time_code, Spherium.OneTimeCode
    field :inserted_at, :naive_datetime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:passkey, :one_time_code_id])
    |> validate_required([:passkey, :one_time_code_id])
    |> unique_constraint(:passkey)
    |> foreign_key_constraint(:one_time_code_id)
  end
end
