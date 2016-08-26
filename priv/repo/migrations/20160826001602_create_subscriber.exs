defmodule SpheriumWebService.Repo.Migrations.CreateSubscriber do
  use Ecto.Migration

  def change do
    create table(:subscribers, primary_key: false) do
      add :id, :integer, default: fragment("nextval('users_id_seq')"), primary_key: true
      add :address, :string

      timestamps()
    end

    create unique_index(:subscribers, [:address])
  end
end
