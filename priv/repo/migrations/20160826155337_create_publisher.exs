defmodule SpheriumWebService.Repo.Migrations.CreatePublisher do
  use Ecto.Migration

  def change do
    create table(:publishers) do
      add :name, :string, null: false
      add :image, :binary
      add :description, :text
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end
    
    create index(:publishers, [:user_id])
  end
end
