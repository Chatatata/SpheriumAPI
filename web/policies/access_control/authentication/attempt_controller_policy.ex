defmodule Spherium.AttemptControllerPolicy do
  def index(conn, _params, :self) do
    is_binary(conn.query_params["username"]) and conn.query_params["username"] =~ conn.assigns[:user].username
  end
end
