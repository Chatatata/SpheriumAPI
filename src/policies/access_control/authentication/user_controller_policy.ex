defmodule Spherium.UserControllerPolicy do
  def show(conn, %{"id" => id}, :self) do
    Integer.to_string(conn.assigns[:user].id) == id
  end

  def update(conn, %{"id" => id}, :self) do
    Integer.to_string(conn.assigns[:user].id) == id
  end

  def delete(conn, %{"id" => id}, :self) do
    Integer.to_string(conn.assigns[:user].id) == id
  end
end
