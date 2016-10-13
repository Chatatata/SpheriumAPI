defmodule Spherium.PassphraseControllerPolicyTest do
  use Spherium.PolicyCase

  alias Spherium.PassphraseControllerPolicy

  test "user wants to access all devices", %{conn: conn} do
    conn = fetch_query_params(conn)

    refute PassphraseControllerPolicy.index(conn, nil, :self)
  end

  test "user wants to access his/her own devices", %{conn: conn} do
    user = conn.assigns[:user]

    conn =
      build_conn(:get, "/?user_id=" <> Integer.to_string(user.id))
      |> fetch_query_params()
      |> assign(:user, user)

    assert PassphraseControllerPolicy.index(conn, nil, :self)
  end
end
