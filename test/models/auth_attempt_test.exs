defmodule SpheriumWebService.AuthAttemptTest do
  use SpheriumWebService.ModelCase

  alias SpheriumWebService.AuthAttempt

  test "changeset with valid attributes" do
    changeset = AuthAttempt.changeset(%AuthAttempt{}, %{success: true, username: "some content", ip_addr: "152.168.7.3"})
    assert changeset.valid?
  end

  test "changeset without username" do
    changeset = AuthAttempt.changeset(%AuthAttempt{}, %{success: true, ip_addr: "152.168.7.3"})
    refute changeset.valid?
  end

  test "changeset without ip address" do
    changeset = AuthAttempt.changeset(%AuthAttempt{}, %{success: true, username: "some content"})
    refute changeset.valid?
  end
end
