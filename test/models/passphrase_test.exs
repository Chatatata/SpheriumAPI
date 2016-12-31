defmodule Spherium.PassphraseTest do
  use Spherium.ModelCase

  alias Spherium.Passphrase
  alias Spherium.Factory

  test "changeset with valid attributes" do
    user = Factory.insert(:user)
    otc = Factory.insert(:one_time_code, user_id: user.id)

    changeset = Passphrase.changeset(%Passphrase{}, %{one_time_code_id: otc.id,
                                                      passkey: Ecto.UUID.generate()})

    assert changeset.valid?
  end

  test "changeset without passkey" do
    user = Factory.insert(:user)
    otc = Factory.insert(:one_time_code, user_id: user.id)

    changeset = Passphrase.changeset(%Passphrase{}, %{one_time_code_id: otc.id})

    refute changeset.valid?
  end

  test "changeset without one time code identifier" do
    changeset = Passphrase.changeset(%Passphrase{}, %{passkey: Ecto.UUID.generate()})

    refute changeset.valid?
  end
end
