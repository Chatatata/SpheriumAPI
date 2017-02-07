defmodule Spherium.PolicyCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a dummy connection to test a policy.
  """

  use ExUnit.CaseTemplate

  alias Spherium.Repo
  alias Spherium.User
  alias Spherium.Passphrase
  alias Spherium.AuthHelper

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
      |> Plug.Conn.assign(:user, user)

    {conn, user}
  end
end
