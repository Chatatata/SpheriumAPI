defmodule Spherium.PassphraseControllerPolicy do
  def index(conn, _params, :self) do
    query_user_id = conn.query_params["user_id"]
    conn_user_id = Integer.to_string(conn.assigns[:user].id)
    is_binary(query_user_id) and query_user_id == conn_user_id
  end
end
