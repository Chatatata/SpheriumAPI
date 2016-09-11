defmodule SpheriumWebService.PlugCase do
  @moduledoc """
  This module defines the test case to be used by
  plug tests.

  You may define functions here to be used as helpers in
  your plug tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn

      alias SpheriumWebService.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
      import SpheriumWebService.PlugCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SpheriumWebService.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SpheriumWebService.Repo, {:shared, self()})
    end

    :ok
  end
end
