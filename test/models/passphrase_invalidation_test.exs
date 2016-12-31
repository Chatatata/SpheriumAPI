defmodule Spherium.PassphraseInvalidationTest do
  use Spherium.ModelCase

  alias Spherium.PassphraseInvalidation
  alias Spherium.Factory

  test "changeset with valid attributes" do
    user = Factory.insert(:user)
    target_otc = Factory.insert(:one_time_code, user_id: user.id)
    target = Factory.insert(:passphrase, one_time_code_id: target_otc.id)
    source_otc = Factory.insert(:one_time_code, user_id: user.id)
    source = Factory.insert(:passphrase, one_time_code_id: source_otc.id)

    changeset =
      PassphraseInvalidation.changeset(
        %PassphraseInvalidation{},
        %{passphrase_id: source.id,
          target_passphrase_id: target.id,
          ip_addr: "0.0.0.0"}
      )

    assert changeset.valid?
  end

  test "changeset without ip address" do
    user = Factory.insert(:user)
    target_otc = Factory.insert(:one_time_code, user_id: user.id)
    target = Factory.insert(:passphrase, one_time_code_id: target_otc.id)
    source_otc = Factory.insert(:one_time_code, user_id: user.id)
    source = Factory.insert(:passphrase, one_time_code_id: source_otc.id)

    changeset =
      PassphraseInvalidation.changeset(
        %PassphraseInvalidation{},
        %{passphrase_id: source.id,
          target_passphrase_id: target.id}
      )

    refute changeset.valid?
  end
end
