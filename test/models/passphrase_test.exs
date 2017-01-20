defmodule Spherium.PassphraseTest do
  use Spherium.ModelCase

  alias Spherium.Passphrase
  alias Spherium.Passkey
  alias Spherium.Factory

  test "changeset with valid attributes" do
    user = Factory.insert(:user)

    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{passkey: Passkey.generate(),
                           user_agent: "ExUnit",
                           user_id: user.id,
                           device: Ecto.UUID.generate()})

    assert changeset.valid?
  end

  test "changeset without user identifier" do
    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{passkey: Passkey.generate()})

    refute changeset.valid?
  end

  test "changeset without passkey" do
    user = Factory.insert(:user)
    otc = Factory.insert(:one_time_code, user_id: user.id)

    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{one_time_code_id: otc.id})

    refute changeset.valid?
  end
end
