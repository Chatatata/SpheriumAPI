defmodule SpheriumWebService.AttemptTest do
  use SpheriumWebService.ModelCase

  alias SpheriumWebService.Attempt

  test "changeset with valid attributes" do
    changeset = Attempt.changeset(%Attempt{}, %{success: true, username: "some content", ip_addr: "152.168.7.3"})
    assert changeset.valid?
  end

  test "changeset without username" do
    changeset = Attempt.changeset(%Attempt{}, %{success: true, ip_addr: "152.168.7.3"})
    refute changeset.valid?
  end

  test "changeset without ip address" do
    changeset = Attempt.changeset(%Attempt{}, %{success: true, username: "some content"})
    refute changeset.valid?
  end
end
