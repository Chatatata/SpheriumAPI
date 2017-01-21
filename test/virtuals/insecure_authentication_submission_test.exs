defmodule Spherium.InsecureAuthenticationSubmissionTest do
  use Spherium.ModelCase

  alias Spherium.InsecureAuthenticationSubmission
  alias Spherium.Passkey

  test "changeset with valid attributes" do
    changeset =
      InsecureAuthenticationSubmission.changeset(%InsecureAuthenticationSubmission{},
                                                 %{passkey: Passkey.generate()})

    assert changeset.valid?
  end

  test "changeset without passkey" do
    changeset =
      InsecureAuthenticationSubmission.changeset(%InsecureAuthenticationSubmission{},
                                                 %{})

    refute changeset.valid?
  end

  test "changeset with invalid passkey" do
    changeset =
      InsecureAuthenticationSubmission.changeset(%InsecureAuthenticationSubmission{},
                                                 %{passkey: "invalid passkey"})

    refute changeset.valid?
  end
end
