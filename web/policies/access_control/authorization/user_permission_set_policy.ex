defmodule Spherium.UserPermissionSetPolicy do
  def show(conn, %{"user_id" => user_id}, :one) do
    user_id =~ conn.assigns[:user].id
  end
end
