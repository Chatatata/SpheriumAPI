defmodule Spherium.PermissionSetGrantPolicy do
  def index(conn, _params, :one) do
    conn.query_params["target_user_id"] == conn.assigns[:user].id
  end
end
