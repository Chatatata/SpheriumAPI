defmodule Spherium.PermissionSetView do
  use Spherium.Web, :view

  def render("index.json", %{permission_sets: permission_sets}) do
    %{data: render_many(permission_sets, Spherium.PermissionSetView, "permission_set.json")}
  end

  def render("show.json", %{permission_set: permission_set}) do
    %{data: render_one(permission_set, Spherium.PermissionSetView, "permission_set.json")}
  end

  def render("permission_set.json", %{permission_set: permission_set}) do
    %{id: permission_set.id,
      name: permission_set.name,
      description: permission_set.description,
      grant_power: permission_set.grant_power,
      user_id: permission_set.user_id,
      permissions: render_many(permission_set.permissions, Spherium.PermissionView, "permission.json")}
  end
end
