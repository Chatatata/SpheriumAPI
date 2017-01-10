defmodule Spherium.Repo.Migrations.PolymorphicAuthenticationSchemes do
  use Ecto.Migration

  def change do
    alter table(:one_time_codes) do
      remove :device
      remove :user_agent
    end

    alter table(:passphrases) do
      add :user_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :device, :uuid, null: false
      add :user_agent, :string, null: false
      remove :one_time_code_id
      add :one_time_code_id, references(:one_time_codes, on_delete: :delete_all, on_update: :update_all)
    end
  end
end
