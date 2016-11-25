defmodule Spherium.Repo.Migrations.RemoveScopeFieldFromUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :scope
    end
  end
end
