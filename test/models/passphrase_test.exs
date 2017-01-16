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

  test "changeset without device identifier" do
    user = Factory.insert(:user)

    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{passkey: Passkey.generate(),
                           user_agent: "ExUnit",
                           user_id: user.id})

    refute changeset.valid?
  end

  test "changeset without user agent" do
    user = Factory.insert(:user)

    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{passkey: Passkey.generate(),
                           device: Ecto.UUID.generate(),
                           user_id: user.id})

    refute changeset.valid?
  end

  test "changeset with one time code identifier" do
    user = Factory.insert(:user, authentication_scheme: :two_factor_over_otc)
    otc = Factory.insert(:one_time_code, user_id: user.id)

    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{passkey: Passkey.generate(),
                             user_id: user.id,
                             device: Ecto.UUID.generate(),
                             user_agent: "ExUnit",
                             one_time_code_id: otc.id})

    assert changeset.valid?
  end

  test "changeset without passkey" do
    user = Factory.insert(:user)
    otc = Factory.insert(:one_time_code, user_id: user.id)

    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{one_time_code_id: otc.id})

    refute changeset.valid?
  end

  test "changeset without one time code identifier" do
    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{passkey: Passkey.generate()})

    refute changeset.valid?
  end
end
