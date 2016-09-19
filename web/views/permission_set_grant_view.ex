defmodule SpheriumWebService.PermissionSetGrantView do
  use SpheriumWebService.Web, :view

  def render("index.json", %{permission_set_grants: permission_set_grants}) do
    %{data: render_many(permission_set_grants, SpheriumWebService.PermissionSetGrantView, "permission_set_grant.json")}
  end

  def render("show.json", %{permission_set_grant: permission_set_grant}) do
    %{data: render_one(permission_set_grant, SpheriumWebService.PermissionSetGrantView, "permission_set_grant.json")}
  end

  def render("permission_set_grant.json", %{permission_set_grant: permission_set_grant}) do
    %{id: permission_set_grant.id,
      controller_name: permission_set_grant.controller_name,
      controller_action: permission_set_grant.controller_action,
      type: permission_set_grant.type}
  end
end
