defmodule Spherium.AttemptPolicy do
  def index(conn, _params, :one) do
    conn.query_params["username"] == conn.assigns[:user].username
  end
end
