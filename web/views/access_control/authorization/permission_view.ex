defmodule SpheriumWebService.PermissionView do
  use SpheriumWebService.Web, :view

  def render("index.json", %{permissions: permissions}) do
    %{data: render_many(permissions, SpheriumWebService.PermissionView, "permission.json")}
  end

  def render("show.json", %{permission: permission}) do
    %{data: render_one(permission, SpheriumWebService.PermissionView, "permission.json")}
  end

  def render("permission.json", %{permission: permission}) do
    %{id: permission.id,
      required_grant_power: permission.required_grant_power,
      controller_name: permission.controller_name,
      controller_action: permission.controller_action,
      type: permission.type}
  end
end
