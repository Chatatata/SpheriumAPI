defmodule Spherium.UserPolicy do
  def show(conn, %{"id" => id}, :one) do
    conn.assigns[:user].id == id
  end

  def update(conn, %{"id" => id}, :one) do
    conn.assigns[:user].id == id
  end

  def delete(conn, %{"id" => id}, :one) do
    conn.assigns[:user].id == id
  end
end
