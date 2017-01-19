defmodule Spherium.OneTimeCodeTest do
  use Spherium.ModelCase

  alias Spherium.OneTimeCode
  alias Spherium.Factory

  @lower_bound 100000
  @upper_bound 1000000

  setup _context do
    %{user: Factory.insert(:user)}
  end

  test "changeset with valid attributes", %{user: user} do
    changeset =
      OneTimeCode.changeset(%OneTimeCode{},
                            %{user_id: user.id,
                              code: 123456})

    assert changeset.valid?
  end

  test "changeset without code", %{user: user} do
    changeset =
      OneTimeCode.changeset(%OneTimeCode{},
                            %{user_id: user.id})

    refute changeset.valid?
  end

  test "changeset without user identifier", %{user: _user} do
    changeset =
      OneTimeCode.changeset(%OneTimeCode{},
                            %{code: 123456})

    refute changeset.valid?
  end

  test "changeset with code below lower bound", %{user: user} do
    changeset =
      OneTimeCode.changeset(%OneTimeCode{},
                            %{user_id: user.id,
                              code: @lower_bound - 1})

    refute changeset.valid?
  end

  test "changeset with code above upper bound", %{user: user} do
    changeset =
      OneTimeCode.changeset(%OneTimeCode{},
                            %{user_id: user.id,
                              code: @upper_bound + 1})

    refute changeset.valid?
  end
end
