defmodule Spherium.Repo.Migrations.AddAuthenticationSchemeEnumType do
  use Ecto.Migration

  def up do
    Spherium.AuthenticationScheme.create_type

    alter table(:users) do
      add :authentication_scheme, :authentication_scheme, null: false, default: "insecure"
    end
  end

  def down do
    alter table(:users) do
      remove :authentication_scheme
    end

    Spherium.AuthenticationScheme.drop_type
  end
end
