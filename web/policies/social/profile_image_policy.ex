defmodule Spherium.ProfileImagePolicy do
  def create(conn, %{"user_id" => user_id, "profile_image" => _profile_image_params}, :one) do
    conn.assigns[:user].id == user_id
  end

  def show(conn, %{"user_id" => user_id}, :one) do
    conn.assigns[:user].id == user_id
  end

  def update(conn, %{"user_id" => user_id, "profile_image" => _profile_image_params}, :one) do
    conn.assigns[:user].id == user_id
  end

  def delete(conn, %{"user_id" => user_id}, :one) do
    conn.assigns[:user].id == user_id
  end
end
