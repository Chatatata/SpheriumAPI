defmodule SpheriumWebService.Repo.Migrations.CreateProfileImage do
  use Ecto.Migration

  def change do
    create table(:profile_images) do
      add :data, :binary, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end
    
    create unique_index(:profile_images, [:user_id])
  end
end
