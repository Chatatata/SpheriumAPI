defmodule Spherium.ServiceCase do
  @moduledoc """
  This module defines the test case to be used by
  service tests.

  You may define functions here to be used as helpers in
  your service tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Spherium.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
      import Spherium.ServiceCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Spherium.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Spherium.Repo, {:shared, self()})
    end

    :ok
  end
end
