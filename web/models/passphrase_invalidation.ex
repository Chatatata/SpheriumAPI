defmodule Spherium.PassphraseInvalidation do
  use Spherium.Web, :model

  schema "passphrase_invalidations" do
    belongs_to :passphrase, Spherium.Passphrase
    belongs_to :target_passphrase, Spherium.Passphrase
    field :ip_addr, :string
    field :inserted_at, Ecto.DateTime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:passphrase_id, :target_passphrase_id, :ip_addr])
    |> validate_required([:passphrase_id, :target_passphrase_id, :ip_addr])
    |> foreign_key_constraint(:passphrase_id)
    |> foreign_key_constraint(:target_passphrase_id)
    |> unique_constraint(:target_passphrase)
  end
end
