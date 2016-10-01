defmodule Spherium.Repo.Migrations.AddValidationFieldToPassphrasesTable do
  use Ecto.Migration

  def change do
    alter table(:passphrases) do
      add :"valid?", :boolean, null: false
    end
  end
end
