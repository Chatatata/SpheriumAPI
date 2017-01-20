defmodule Spherium.Repo.Migrations.CreateUserIdIdxOnOneTimeCodes do
  use Ecto.Migration

  def change do
    create index(:one_time_codes, [:user_id])
  end
end
