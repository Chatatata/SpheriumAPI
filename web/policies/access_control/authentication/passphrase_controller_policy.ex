defmodule Spherium.PassphraseControllerPolicy do
  def index(conn, _params, :self) do
    is_binary(conn.query_params["user_id"]) and conn.query_params["user_id"] =~ Integer.to_string(conn.assigns[:user].id)
  end
end
