defmodule SpheriumWebService.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
	  add :email, :string
      add :password_digest, :string
      add :scope, {:array, :string}, default: []
      add :activation_key, :uuid, default: fragment("uuid_generate_v4()")
	  add :activation_date, :datetime, default: nil

      timestamps
    end
	
    create unique_index(:users, [:username])
	create unique_index(:emails, [:email])
  end
end
