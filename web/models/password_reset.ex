defmodule Spherium.PasswordReset do
  use Spherium.Web, :model

  schema "password_resets" do
    belongs_to :user, Spherium.User
    field :inserted_at, :naive_datetime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id])
    |> validate_required([:user_id])
    |> foreign_key_constraint(:user_id)
  end
end
