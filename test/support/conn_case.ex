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
  alias Spherium.OneTimeCode

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
        user = Repo.get_by!(User, username: "onesadmin")
        otc = Repo.get_by!(OneTimeCode, user_id: user.id)
        passphrase = Repo.get_by!(Passphrase, one_time_code_id: otc.id)

        conn =
          conn
          |> Plug.Conn.put_req_header("accept", "application/json")
          |> AuthHelper.issue_token(user, passphrase)
          |> Plug.Conn.assign(:setup_user, user)

        {:ok, conn: conn}
      tags[:super_cow_powers] != false ->
        user = Repo.get_by!(User, username: "superadmin")
        otc = Repo.get_by!(OneTimeCode, user_id: user.id)
        passphrase = Repo.get_by!(Passphrase, one_time_code_id: otc.id)

        conn =
          conn
          |> Plug.Conn.put_req_header("accept", "application/json")
          |> AuthHelper.issue_token(user, passphrase)
          |> Plug.Conn.assign(:setup_user, user)

        {:ok, conn: conn}
      true ->
        {:ok, conn: conn}
    end
  end
end
