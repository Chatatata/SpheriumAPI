defmodule Spherium.PermissionSetGrantControllerPolicy do
  def index(conn, _params, :self) do
    target_user_id = conn.query_params["target_user_id"]
    conn_user_id = Integer.to_string(conn.assigns[:user].id)

    is_binary(target_user_id) and target_user_id == conn_user_id
  end

  def index(_conn, _params, :all) do
    true
  end
end
