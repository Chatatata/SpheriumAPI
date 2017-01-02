defmodule Spherium.Repo.Migrations.CreateAttempt do
  use Ecto.Migration

  def change do
    create table(:attempts) do
      add :ip_addr, :string, null: false
      add :username, :string, null: false
      add :success, :boolean, default: false
      add :inserted_at, :naive_datetime, null: false, default: fragment("now()")
    end

    create index(:attempts, [:username])
  end
end
