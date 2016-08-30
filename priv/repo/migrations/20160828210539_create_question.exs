defmodule SpheriumWebService.Repo.Migrations.CreateQuestion do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :publisher_id, references(:publishers, on_delete: :nothing), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end
    
    create index(:questions, [:publisher_id])
    create index(:questions, [:user_id])
  end
end
