defmodule Spherium.PassphraseInvalidationTest do
  use Spherium.ModelCase

  alias Spherium.PassphraseInvalidation
  alias Spherium.Factory

  test "changeset with valid attributes" do
    user = Factory.insert(:user)
    passphrases = Factory.insert_list(2, :passphrase, user_id: user.id)

    changeset = PassphraseInvalidation.changeset(%PassphraseInvalidation{}, %{passphrase_id: Enum.at(passphrases, 0).id,
                                                                              target_passphrase_id: Enum.at(passphrases, 1).id,
                                                                              ip_addr: "0.0.0.0"})

    assert changeset.valid?
  end

  test "changeset without ip address" do
    user = Factory.insert(:user)
    passphrases = Factory.insert_list(2, :passphrase, user_id: user.id)

    changeset = PassphraseInvalidation.changeset(%PassphraseInvalidation{}, %{passphrase_id: Enum.at(passphrases, 0).id,
                                                                              target_passphrase_id: Enum.at(passphrases, 1).id})

    refute changeset.valid?
  end
end
