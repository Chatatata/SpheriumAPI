defmodule Spherium.OneTimeCode do
  use Spherium.Web, :model

  schema "one_time_codes" do
    belongs_to :user, Spherium.User
    field :code, :integer
    field :inserted_at, :naive_datetime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :code])
    |> validate_required([:user_id, :code])
    |> foreign_key_constraint(:user_id)
  end
end
