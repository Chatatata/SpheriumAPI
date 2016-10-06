defmodule Spherium.Repo.Migrations.AddPassphrasesTable do
  use Ecto.Migration

  def change do
    create table(:passphrases) do
      add :passkey, :string, size: 88, null: false
      add :user_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :device, :uuid, null: false
      add :user_agent, :string, null: false
      add :inserted_at, :timestamp, null: false, default: fragment("now()")
    end

    create table(:passphrase_invalidations) do
      add :passphrase_id, references(:passphrases, on_delete: :delete_all, on_update: :update_all), null: false
      add :target_passphrase_id, references(:passphrases, on_delete: :delete_all, on_update: :update_all), null: false
      add :inserted_at, :timestamp, null: false, default: fragment("now()")
      add :ip_addr, :string, null: false
    end

    create unique_index(:passphrases, [:passkey])
    create unique_index(:passphrase_invalidations, [:target_passphrase_id])
  end
end
