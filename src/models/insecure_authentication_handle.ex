defmodule Spherium.InsecureAuthenticationHandle do
  use Spherium.Web, :model

  schema "insecure_authentication_handles" do
    belongs_to :user, Spherium.User
    field :passkey, :string
    field :inserted_at, :naive_datetime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :passkey])
    |> validate_required([:user_id, :passkey])
    |> foreign_key_constraint(:user_id)
  end
end
