defmodule Spherium.PassphraseInvalidationTest do
  use Spherium.ModelCase

  alias Spherium.PassphraseInvalidation
  alias Spherium.Factory

  test "changeset with valid attributes" do
    user = Factory.insert(:user, authentication_scheme: :two_factor_over_otc)
    target = Factory.insert(:passphrase, user_id: user.id)
    source = Factory.insert(:passphrase, user_id: user.id)

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
    user = Factory.insert(:user, authentication_scheme: :two_factor_over_otc)
    target = Factory.insert(:passphrase, user_id: user.id)
    source = Factory.insert(:passphrase, user_id: user.id)

    changeset =
      PassphraseInvalidation.changeset(
        %PassphraseInvalidation{},
        %{passphrase_id: source.id,
          target_passphrase_id: target.id}
      )

    refute changeset.valid?
  end

  test "changeset with valid attributes (regression)" do
    user = Factory.insert(:user, authentication_scheme: :two_factor_over_otc)
    target = Factory.insert(:passphrase, user_id: user.id)
    source = Factory.insert(:passphrase, user_id: user.id)

    changeset =
      PassphraseInvalidation.changeset(
        %PassphraseInvalidation{},
        %{passphrase_id: source.id,
          target_passphrase_id: target.id,
          ip_addr: "0.0.0.0"}
      )

    assert changeset.valid?
  end

  test "changeset without ip address (regression)" do
    user = Factory.insert(:user, authentication_scheme: :two_factor_over_otc)
    target = Factory.insert(:passphrase, user_id: user.id)
    source = Factory.insert(:passphrase, user_id: user.id)

    changeset =
      PassphraseInvalidation.changeset(
        %PassphraseInvalidation{},
        %{passphrase_id: source.id,
          target_passphrase_id: target.id}
      )

    refute changeset.valid?
  end
end
