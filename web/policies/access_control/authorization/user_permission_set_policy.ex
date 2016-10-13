defmodule Spherium.UserPermissionSetControllerPolicy do
  def show(conn, %{"user_id" => user_id}, :self) do
    user_id =~ Integer.to_string(conn.assigns[:user].id)
  end
end
