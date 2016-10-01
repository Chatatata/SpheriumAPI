defmodule Spherium.PassphraseInvalidation do
  use Spherium.Web, :model

  @primary_key false

  schema "passphrase_invalidations" do
    belongs_to :passphrase, Spherium.User
    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:passphrase_id])
    |> foreign_key_constraint(:passphrase_id)
  end
end
