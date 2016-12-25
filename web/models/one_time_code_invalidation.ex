defmodule Spherium.OneTimeCodeInvalidation do
  use Spherium.Web, :model

  schema "one_time_code_invalidations" do
    belongs_to :one_time_code, Spherium.OneTimeCode
    field :inserted_at, :naive_datetime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:one_time_code_id])
    |> validate_required([:one_time_code_id])
    |> foreign_key_constraint(:one_time_code_id)
  end
end
