defmodule SpheriumWebService.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
	    add :email, :string
      add :password_digest, :string, null: false
      add :scope, {:array, :string}, default: []
      add :activation_key, :uuid, default: fragment("uuid_generate_v4()"), null: false
	    add :activation_date, :datetime, default: fragment("now()")

      timestamps
    end
	
    create unique_index(:users, [:username])
	  create unique_index(:users, [:email])
  end
end
