defmodule Spherium.PermissionSetGrantControllerPolicy do
  def index(conn, _params, :self) do
    is_binary(conn.query_params["target_user_id"]) and conn.query_params["target_user_id"] =~ Integer.to_string(conn.assigns[:user].id)
  end
end
