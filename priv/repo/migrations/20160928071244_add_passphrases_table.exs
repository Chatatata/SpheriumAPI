defmodule Spherium.Repo.Migrations.AddPassphrasesTable do
  use Ecto.Migration

  def change do
    create table(:passphrases, primary_key: false) do
      add :passkey, :uuid, default: fragment("uuid_generate_v4()"), null: false, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :device, :uuid, null: false
      add :user_agent, :string, null: false
    end
  end
end
