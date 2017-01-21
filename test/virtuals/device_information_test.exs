defmodule Spherium.DeviceInformationTest do
  use Spherium.ModelCase

  alias Spherium.DeviceInformation

  test "changeset with valid attributes" do
    changeset =
      DeviceInformation.changeset(%DeviceInformation{},
                                  %{device: Ecto.UUID.generate(),
                                    user_agent: "ExUnit"})

    assert changeset.valid?
  end

  test "changeset without device identifier" do
    changeset =
      DeviceInformation.changeset(%DeviceInformation{},
                                  %{user_agent: "ExUnit"})

    refute changeset.valid?
  end

  test "changeset without user agent" do
    changeset =
      DeviceInformation.changeset(%DeviceInformation{},
                                  %{device: Ecto.UUID.generate()})

    refute changeset.valid?
  end

  test "changeset with malformed device identifier" do
    changeset =
      DeviceInformation.changeset(%DeviceInformation{},
                                  %{device: "malformed identifier",
                                    user_agent: "ExUnit"})

    refute changeset.valid?
  end
end
