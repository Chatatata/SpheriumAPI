defmodule Spherium.InsecureAuthenticationSubmissionTest do
  use Spherium.ModelCase

  alias Spherium.InsecureAuthenticationSubmission
  alias Spherium.Factory
  alias Spherium.Passkey

  setup _context do
    %{user: Factory.insert(:user)}
  end

  test "changeset with valid attributes", %{user: user} do
    changeset =
      InsecureAuthenticationSubmission.changeset(%InsecureAuthenticationSubmission{},
                                                 %{user_id: user.id,
                                                   passkey: Passkey.generate()})

    assert changeset.valid?
  end

  test "changeset without user identifier", %{user: _user} do
    changeset =
      InsecureAuthenticationSubmission.changeset(%InsecureAuthenticationSubmission{},
                                                 %{passkey: Passkey.generate()})

    refute changeset.valid?
  end

  test "changeset without passkey", %{user: user} do
    changeset =
      InsecureAuthenticationSubmission.changeset(%InsecureAuthenticationSubmission{},
                                                 %{user_id: user.id})

    refute changeset.valid?
  end

  test "changeset with invalid passkey", %{user: user} do
    changeset =
      InsecureAuthenticationSubmission.changeset(%InsecureAuthenticationSubmission{},
                                                 %{user_id: user.id,
                                                   passkey: "invalid passkey"})

    refute changeset.valid?
  end
end
