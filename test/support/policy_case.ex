defmodule Spherium.PolicyCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a dummy connection to test a policy.
  """

  use ExUnit.CaseTemplate

  alias Spherium.Factory

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Spherium.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]

      import Spherium.Router.Helpers
      import Plug.Conn

      # The default endpoint for testing
      @endpoint Spherium.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Spherium.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Spherium.Repo, {:shared, self()})
    end

    user = Factory.insert(:user)

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.assign(:user, user)

    {:ok, conn: conn}
  end
end
