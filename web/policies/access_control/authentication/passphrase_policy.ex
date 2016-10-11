defmodule Spherium.PassphrasePolicy do
  def index(conn, _params, :one) do
    user_id =
      conn.query_params["user_id"]
      |> Integer.parse()
      |> Kernel.elem(0)

    user_id == conn.assigns[:user].id
  end
end
