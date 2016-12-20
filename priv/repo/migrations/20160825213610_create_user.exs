defmodule Spherium.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\""

    create table(:users) do
      add :username, :string, null: false
	    add :email, :string
      add :password_digest, :string, null: false
      add :scope, {:array, :string}, default: []
      add :activation_key, :uuid, default: fragment("uuid_generate_v4()"), null: false
	    add :activation_date, :naive_datetime, default: fragment("now()")
      add :inserted_at, :naive_datetime, default: fragment("now()"), null: false
      add :updated_at, :naive_datetime
    end

    create unique_index(:users, [:username])
	  create unique_index(:users, [:email])
  end
end
