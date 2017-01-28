defmodule Spherium.AuthorizationPlug do
  use Spherium.Web, :plug

  alias Spherium.User
  alias Spherium.PermissionSet
  alias Spherium.Permission
  alias Spherium.Repo

  import Ecto.Query

  def authorize_user(conn, available_types) do
    # The resource we want to access
    user = conn.assigns[:user]
    controller_name = Atom.to_string conn.private.phoenix_controller
    controller_action = Atom.to_string conn.private.phoenix_action

    available_types = Enum.map(available_types, &Atom.to_string/1)

    query = from u in User,
            join: ps in PermissionSet, on: u.permission_set_id == ps.id,
            join: psp in "permission_set_permissions", on: psp.permission_set_id == ps.id,
            join: p in Permission, on: psp.permission_id == p.id,
            where: u.id == ^user.id and
                   p.controller_name == ^controller_name and
                   p.controller_action == ^controller_action and
                   p.type in ^available_types,
            select: p.type,
            order_by: p.type,
            limit: 1

    if permission_type = Repo.one(query) do
      conn
      |> assign(:permission_type, String.to_atom(permission_type))
    else
      conn
      |> put_status(:unauthorized)
      |> Phoenix.Controller.render(Spherium.PermissionErrorView, "unauthorized.json")
      |> halt()
    end
  end

  def apply_policy(conn, _params) do
    policy_module = fetch_policy_module(conn)

    unless conn.assigns[:permission_type] == :all or
           Kernel.apply(policy_module, conn.private.phoenix_action, [conn, conn.params, conn.assigns[:permission_type]]) do
      conn
      |> put_status(:unauthorized)
      |> Phoenix.Controller.render(Spherium.PermissionErrorView, "unauthorized.json")
      |> halt()
    else
      conn
    end
  end

  defp fetch_policy_module(conn) do
    controller_name = Atom.to_string conn.private.phoenix_controller
    String.to_atom(controller_name <> "Policy")
  end
end
