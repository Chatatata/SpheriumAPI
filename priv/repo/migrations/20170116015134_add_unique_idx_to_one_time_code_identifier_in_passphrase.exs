defmodule Spherium.Repo.Migrations.AddUniqueIdxToOneTimeCodeIdentifierInPassphrase do
  use Ecto.Migration

  def change do
    create index(:passphrases, [:one_time_code_id], unique: true)
  end
end
