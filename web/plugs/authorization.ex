defmodule Spherium.AuthorizationPlug do
  use Spherium.Web, :plug

  alias Spherium.User
  alias Spherium.PermissionSet
  alias Spherium.Permission
  alias Spherium.Repo

  import Ecto.Query

  def authorize_user(conn, _opts) do
    # The resource we want to access
    user = conn.assigns[:user]
    controller_name = Atom.to_string conn.private.phoenix_controller
    controller_action = Atom.to_string conn.private.phoenix_action

    if permission_type = check_for_controller_action_permission(user, controller_name, controller_action) do
      conn
      |> assign(:permission_type, String.to_atom(permission_type))
    else
      conn
      |> halt
      |> put_status(:unauthorized)
      |> Phoenix.Controller.render(Spherium.PermissionErrorView, "unauthorized.json")
    end
  end

  # TODO: Check permission type
  defp check_for_controller_action_permission(user, controller_name, controller_action) do
    query = from u in User,
            join: ps in PermissionSet, on: u.permission_set_id == ps.id,
            join: psp in "permission_set_permissions", on: psp.permission_set_id == ps.id,
            join: p in Permission, on: psp.permission_id == p.id,
            where: u.id == ^user.id and p.controller_name == ^controller_name and p.controller_action == ^controller_action,
            select: p.type,
            order_by: p.type,
            limit: 1

     Repo.one(query)
  end
end
