defmodule Spherium.InsecureAuthenticationSubmission do
  use Spherium.Web, :model

  schema "insecure_authentication_submissions" do
    field :passkey, :string
    belongs_to :user, Spherium.User
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:passkey, :user_id])
    |> validate_required([:passkey, :user_id])
    |> unique_constraint(:passkey)
  end
end
