defmodule SpheriumWebService.Repo.Migrations.CreateAttempt do
  use Ecto.Migration

  def change do
    create table(:attempts) do
      add :ip_addr, :string, null: false
      add :username, :string, null: false
      add :success, :boolean, default: false

      timestamps()
    end

    create index(:attempts, [:username])
  end
end
