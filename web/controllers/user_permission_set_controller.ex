defmodule SpheriumWebService.UserPermissionSetController do
  use SpheriumWebService.Web, :controller

  alias SpheriumWebService.User
  alias SpheriumWebService.PermissionSet

  plug :put_view, SpheriumWebService.PermissionSetView

  def show(conn, %{"user_id" => user_id}) do
    query = from u in User,
            join: ps in PermissionSet, on: ps.id == u.permission_set_id,
            where: u.id == ^user_id,
            select: ps

    permission_set = Repo.one!(query)
                     |> Repo.preload(:permissions)

    render conn, "show.json", permission_set: permission_set
  end

  def update(conn, %{"user_id" => user_id, "permission_set_id" => permission_set_id}) do
    try do
      query = from u in User,
              where: u.id == ^user_id

      case Repo.update_all(query, set: [permission_set_id: permission_set_id]) do
        {1, _terms} -> render(conn, "show.json", permission_set: Repo.get!(PermissionSet, permission_set_id) |> Repo.preload(:permissions))
        {0, _terms} -> send_resp(conn, :not_found, "User not found.")
      end
    rescue
      Postgrex.Error -> send_resp(conn, :not_found, "Permission set with given identifier not found.")
    end
  end

  def delete(conn, %{"user_id" => user_id}) do
    query = from u in User,
            where: u.id == ^user_id

    # FIXME: Permission set identifier field of user not get set to NULL.
    case Repo.update_all(query, set: [permission_set_id: nil]) do
      {1, _terms} -> send_resp(conn, :no_content, "Permission set successfully unassigned from user.")
      {0, _terms} -> send_resp(conn, :not_found, "User not found.")
    end
  end
end
