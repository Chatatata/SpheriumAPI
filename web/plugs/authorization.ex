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

    if check_for_controller_action_permission(user, controller_name, controller_action) do
      conn
    else
      conn
      |> halt()
      |> send_resp(403, "You are unauthorized to see this entity.")
    end
  end

  # TODO: Check permission type
  defp check_for_controller_action_permission(user, controller_name, controller_action) do
    query = from result in subquery(
              from u in User,
              join: ps in PermissionSet, on: u.permission_set_id == ps.id,
              join: psp in "permission_set_permissions", on: psp.permission_set_id == ps.id,
              join: p in Permission, on: psp.permission_id == p.id,
              where: u.id == ^user.id and p.controller_name == ^controller_name and p.controller_action == ^controller_action,
              select: {u.id, p.controller_name, p.controller_action, p.type},
              limit: 1
            ),
            select: fragment("count(*)")

     Repo.all(query) == [1]
  end
end
