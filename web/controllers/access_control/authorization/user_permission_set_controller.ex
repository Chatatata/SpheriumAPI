defmodule SpheriumWebService.UserPermissionSetController do
  use SpheriumWebService.Web, :controller

  alias SpheriumWebService.User
  alias SpheriumWebService.PermissionSet
  alias SpheriumWebService.PermissionSetGrant

  plug :authenticate_user
  plug :authorize_user
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

      case Repo.transaction(fn ->
        case Repo.update_all(query, set: [permission_set_id: permission_set_id]) do
          {1, _terms} ->
            # Permission set of user is successfully updated.
            changeset = PermissionSetGrant.changeset(%PermissionSetGrant{}, %{permission_set_id: permission_set_id,
                                                                              user_id: conn.assigns[:user].id,
                                                                              target_user_id: user_id})

            Repo.insert!(changeset)
          {0, _terms} ->
            # No permission set of a user is updated.
            Repo.rollback(:user_not_found)
        end
      end) do
        {:ok, _permission_set_grant} -> render(conn, "show.json", permission_set: Repo.get!(PermissionSet, permission_set_id) |> Repo.preload(:permissions))
        {:error, :user_not_found} -> send_resp(conn, :not_found, "User not found.")
      end
    rescue
      Postgrex.Error -> send_resp(conn, :not_found, "Permission set with given identifier not found.")
    end
  end

  def delete(conn, %{"user_id" => user_id}) do
    query = from u in User,
            where: u.id == ^user_id

    case Repo.update_all(query, set: [permission_set_id: nil]) do
      {1, _terms} -> send_resp(conn, :no_content, "Permission set successfully unassigned from user.")
      {0, _terms} -> send_resp(conn, :not_found, "User not found.")
    end
  end
end
