defmodule Spherium.OneTimeCodeSubmissionTest do
  use Spherium.ModelCase

  alias Spherium.OneTimeCodeSubmission
  alias Spherium.Factory

  @upper_bound 999999
  @lower_bound 100000

  setup _context do
    user = Factory.insert(:user)

    %{user: user}
  end

  test "changeset with valid attributes", %{user: user} do
    changeset =
      OneTimeCodeSubmission.changeset(%OneTimeCodeSubmission{},
                                      %{code: 500000,
                                        user_id: user.id})

    assert changeset.valid?
  end

  test "changeset without code", %{user: user} do
    changeset =
      OneTimeCodeSubmission.changeset(%OneTimeCodeSubmission{},
                                      %{user_id: user.id})

    refute changeset.valid?
  end

  test "changeset without user identifier" do
    changeset =
      OneTimeCodeSubmission.changeset(%OneTimeCodeSubmission{},
                                      %{code: 500000})

    refute changeset.valid?
  end

  test "changeset with a code underneath lower bound", %{user: user} do
    changeset =
      OneTimeCodeSubmission.changeset(%OneTimeCodeSubmission{},
                                      %{code: @lower_bound - :rand.uniform(@lower_bound) - 1 ,
                                        user_id: user.id})

    refute changeset.valid?
  end

  test "changeset with a code beneath upper bound", %{user: user} do
    changeset =
      OneTimeCodeSubmission.changeset(%OneTimeCodeSubmission{},
                                      %{code: :rand.uniform(100) + @upper_bound + 1,
                                        user_id: user.id})

    refute changeset.valid?
  end

  test "changeset with a code on lower bound", %{user: user} do
    changeset =
      OneTimeCodeSubmission.changeset(%OneTimeCodeSubmission{},
                                      %{code: @lower_bound - 1,
                                        user_id: user.id})

    refute changeset.valid?
  end

  test "changeset with a code on upper bound", %{user: user} do
    changeset =
      OneTimeCodeSubmission.changeset(%OneTimeCodeSubmission{},
                                      %{code: @upper_bound + 1,
                                        user_id: user.id})

    refute changeset.valid?
  end
end
