defmodule Spherium.Repo.Migrations.RemoveUnban do
  use Ecto.Migration

  def change do
    drop_if_exists table(:unban)
  end
end
