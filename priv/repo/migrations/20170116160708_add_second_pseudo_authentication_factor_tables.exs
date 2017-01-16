defmodule Spherium.Repo.Migrations.AddSecondPseudoAuthenticationFactorTables do
  use Ecto.Migration

  def change do
    create table(:insecure_authentication_handles) do
      add :user_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :passkey, :string, size: 88, null: false
      add :inserted_at, :naive_datetime, null: false, default: fragment("now()")
    end
  end
end
