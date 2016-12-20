defmodule Spherium.Repo.Migrations.AddPasswordResetsTable do
  use Ecto.Migration

  def change do
    create table(:password_resets) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :inserted_at, :naive_datetime, null: false, default: fragment("now()")
    end

    alter table(:passphrase_invalidations) do
      remove :passphrase_id
      add :passphrase_id, references(:passphrases, on_delete: :delete_all, on_update: :update_all), null: true
    end
  end
end
