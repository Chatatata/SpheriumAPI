defmodule Spherium.PasswordControllerPolicy do
  def update(conn, %{"user_id" => user_id}, _) when is_binary(user_id) do
    user_id == Integer.to_string(conn.assigns[:user].id)
  end

  def update(conn, %{"user_id" => user_id}, _) do
    user_id == conn.assigns[:user].id
  end
end
