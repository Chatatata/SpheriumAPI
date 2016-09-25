defmodule SpheriumWebService.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """
  alias SpheriumWebService.Repo
  alias SpheriumWebService.User
  alias SpheriumWebService.AuthHelper

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias SpheriumWebService.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]

      import SpheriumWebService.Router.Helpers

      # The default endpoint for testing
      @endpoint SpheriumWebService.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SpheriumWebService.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SpheriumWebService.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()

    unless (tags[:super_cow_powers] == false) do
      user = Repo.get_by!(User, username: "superadmin")

      conn =
        conn
        |> Plug.Conn.put_req_header("accept", "application/json")
        |> AuthHelper.issue_token(user)
        |> Plug.Conn.assign(:setup_user, user)

      {:ok, conn: conn}
    else
      {:ok, conn: conn}
    end
  end
end
