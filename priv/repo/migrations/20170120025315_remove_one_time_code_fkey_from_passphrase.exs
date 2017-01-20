defmodule Spherium.Repo.Migrations.RemoveOneTimeCodeFkeyFromPassphrase do
  use Ecto.Migration

  def change do
    alter table(:passphrases) do
      remove :one_time_code_id
    end
  end
end
