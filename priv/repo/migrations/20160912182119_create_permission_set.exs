defmodule Spherium.Repo.Migrations.CreateAuthorizationTables do
  use Ecto.Migration

  def change do
    # Create the table which holds permission sets.
    create table(:permission_sets) do
      add :name, :string, null: false, size: 50
      add :description, :string, null: false
      add :grant_power, :integer, null: false, default: 0
      add :user_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :inserted_at, :timestamp, null: false, default: fragment("now()")
    end

    # Each user should belong to one permission set.
    alter table(:users) do
      add :permission_set_id, references(:permission_sets, on_delete: :nilify_all, on_update: :update_all)
    end

    # Create the table which holds permissions.
    create table(:permissions) do
      add :required_grant_power, :integer, null: false
      add :controller_name, :string, null: false, size: 100
      add :controller_action, :string, null: false, size: 30
      add :type, :string, null: false, size: 30
    end

    # Create the table which holds permissions of permission sets.
    create table(:permission_set_permissions, primary_key: false) do
      add :permission_set_id, references(:permission_sets, on_delete: :delete_all, on_update: :update_all), null: false
      add :permission_id, references(:permissions, on_delete: :delete_all, on_update: :update_all), null: false
    end

    # Create the table which holds permission set grants.
    create table(:permission_set_grants) do
      add :permission_set_id, references(:permission_sets, on_delete: :delete_all, on_update: :update_all), null: false
      add :user_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :target_user_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :inserted_at, :timestamp, null: false, default: fragment("now()")
    end

    create unique_index(:permissions, [:controller_name, :controller_action, :type], name: :permissions_unique_coupling)
    create constraint(:permissions, "required_grant_power_is_smaller_than_1000", check: "required_grant_power < 1000")

    create index(:permission_sets, [:user_id])
    create unique_index(:permission_sets, [:name])
    create constraint(:permission_sets, "grant_power_is_smaller_than_1000", check: "grant_power < 1000")

    create unique_index(:permission_set_permissions, [:permission_set_id, :permission_id], name: :permission_set_permissions_pkey)

    create index(:permission_set_grants, [:user_id, :target_user_id])
  end
end
