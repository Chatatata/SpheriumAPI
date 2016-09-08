defmodule SpheriumWebService.Repo.Migrations.CreateAuthAttempt do
  use Ecto.Migration

  def change do
    create table(:auth_attempts) do
      add :ip_addr, :string, null: false
      add :username, :string, null: false
      add :success, :boolean, default: false

      timestamps()
    end

    create index(:auth_attempts, [:username])
  end
end
