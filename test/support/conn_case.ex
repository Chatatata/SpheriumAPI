defmodule Spherium.ConnCase do
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
  alias Spherium.Repo
  alias Spherium.User
  alias Spherium.Passphrase
  alias Spherium.AuthHelper

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Spherium.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]

      import Spherium.Router.Helpers

      # The default endpoint for testing
      @endpoint Spherium.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Spherium.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Spherium.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()

    cond do
      tags[:attach_to_one_permissions] == true ->
        {conn, user} = fetch_and_assign_token(conn, "onesadmin")

        {:ok, conn: conn, user: user}
      tags[:super_cow_powers] != false ->
        {conn, user} = fetch_and_assign_token(conn, "superadmin")

        {:ok, conn: conn, user: user}
      true ->
        {:ok, conn: conn}
    end
  end

  defp fetch_and_assign_token(conn, name) do
    user = Repo.get_by!(User, username: name)
    passphrase = Repo.get_by!(Passphrase, user_id: user.id)

    conn =
      conn
      |> Plug.Conn.put_req_header("accept", "application/json")
      |> AuthHelper.issue_token(user, passphrase)
      |> Plug.Conn.assign(:setup_user, user)

    {conn, user}
  end
end
