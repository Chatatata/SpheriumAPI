defmodule Spherium.PassphraseTest do
  use Spherium.ModelCase

  alias Spherium.Passphrase
  alias Spherium.Factory

  test "changeset with valid attributes" do
    user = Factory.insert(:user)

    changeset = Passphrase.changeset(%Passphrase{}, %{user_id: user.id,
                                                      device: Ecto.UUID.generate(),
                                                      user_agent: "Testing user agent on ExUnit (some_agent) v1.4.2"})

    assert changeset.valid?
  end

  test "changeset without device identifier" do
    user = Factory.insert(:user)

    changeset = Passphrase.changeset(%Passphrase{}, %{user_id: user.id,
                                                      user_agent: "Testing user agent on ExUnit (some_agent) v1.4.2"})

    refute changeset.valid?
  end

  test "changeset without user agent" do
    user = Factory.insert(:user)

    changeset = Passphrase.changeset(%Passphrase{}, %{user_id: user.id,
                                                      device: Ecto.UUID.generate()})

    refute changeset.valid?
  end
end
