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
      permission_set_id: permission_set_grant.permission_set_id,
      authority_id: permission_set_grant.user_id,
      grant_target_id: permission_set_grant.target_user_id,
      timestamp: permission_set_grant.inserted_at}
  end
end
