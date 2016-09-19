defmodule SpheriumWebService.AuthorizationPlug do
  use SpheriumWebService.Web, :plug

  alias SpheriumWebService.User
  alias SpheriumWebService.PermissionSet
  alias SpheriumWebService.Permission
  alias SpheriumWebService.PermissionSetPermissions
  alias SpheriumWebService.ControllerAccessPermission
  alias SpheriumWebService.Repo

  import Ecto.Query

  def authorize_user(conn, _opts) do
    # The resource we want to access
    user = conn.assigns[:user]
    controller_name = Atom.to_string conn.private.phoenix_controller
    controller_action = Atom.to_string conn.private.phoenix_action

    if check_for_controller_action_permission(user, controller_name, controller_action) do
      conn
    else
      conn
      |> halt()
      |> send_resp(403, "You are unauthorized to see this entity.")
    end
  end

  defp check_for_controller_action_permission(user, controller_name, controller_action) do
    query = from result in subquery(
              from u in User,
              join: ps in PermissionSet, on: u.permission_set_id == ps.id,
              join: psp in PermissionSetPermissions, on: psp.permission_set_id == ps.id,
              join: p in Permission, on: psp.permission_id == p.id,
              join: cap in ControllerAccessPermission, on: cap.id == p.controller_access_permission_id,
              where: u.id == ^user.id and cap.controller_name == ^controller_name and cap.controller_action == ^controller_action,
              select: {u.id, cap.controller_name, cap.controller_action, cap.type},
              limit: 1
            ),
            select: fragment("count(*)")

     Repo.all(query) == [1]
  end
end
