defmodule Spherium.OneTimeCodeInvalidationTest do
  use Spherium.ModelCase

  alias Spherium.OneTimeCodeInvalidation
  alias Spherium.Factory

  setup _context do
    user = Factory.insert(:user)
    %{user: user,
      one_time_code: Factory.insert(:one_time_code, user: user)}
  end

  test "changeset with valid attributes", %{one_time_code: one_time_code} do
    changeset =
      OneTimeCodeInvalidation.changeset(%OneTimeCodeInvalidation{},
                                        %{one_time_code_id: one_time_code.id})

    assert changeset.valid?
  end

  test "changeset without one time code identifier", %{one_time_code: _one_time_code} do
    changeset =
      OneTimeCodeInvalidation.changeset(%OneTimeCodeInvalidation{},
                                        %{})

    refute changeset.valid?
    assert {:one_time_code_id, {"can't be blank", [validation: :required]}} in changeset.errors
  end
end
