defmodule SpheriumWebService.PermissionTest do
  use SpheriumWebService.ModelCase

  alias SpheriumWebService.Permission

  test "changeset with valid attributes" do
    changeset = Permission.changeset(%Permission{}, %{required_grant_power: 500,
                                                      controller_name: "Elixir.SpheriumWebService.RegularController",
                                                      controller_action: "index",
                                                      type: "all"})

    assert changeset.valid?
  end

  test "changeset without grant power" do
    changeset = Permission.changeset(%Permission{}, %{controller_name: "Elixir.SpheriumWebService.RegularController",
                                                      controller_action: "index",
                                                      type: "all"})

    refute changeset.valid?
  end

  test "changeset with exceeding grant power" do
    changeset = Permission.changeset(%Permission{}, %{required_grant_power: 1001,
                                                      controller_name: "Elixir.SpheriumWebService.RegularController",
                                                      controller_action: "index",
                                                      type: "all"})

    refute changeset.valid?
  end

  test "changeset with negative grant power" do
    changeset = Permission.changeset(%Permission{}, %{required_grant_power: -500,
                                                      controller_name: "Elixir.SpheriumWebService.RegularController",
                                                      controller_action: "index",
                                                      type: "all"})

    refute changeset.valid?
  end

  test "changeset without controller name" do
    changeset = Permission.changeset(%Permission{}, %{required_grant_power: 500,
                                                      controller_action: "index",
                                                      type: "all"})

    refute changeset.valid?
  end

  test "changeset without controller action" do
    changeset = Permission.changeset(%Permission{}, %{required_grant_power: 500,
                                                      controller_name: "Elixir.SpheriumWebService.RegularController",
                                                      type: "all"})

    refute changeset.valid?
  end

  test "changeset without type" do
    changeset = Permission.changeset(%Permission{}, %{required_grant_power: 500,
                                                      controller_name: "Elixir.SpheriumWebService.RegularController",
                                                      controller_action: "index"})

    refute changeset.valid?
  end
end
