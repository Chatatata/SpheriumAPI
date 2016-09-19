defmodule SpheriumWebService.PermissionController do
  @moduledoc """
  Handles permission endpoints.
  """
  use SpheriumWebService.Web, :controller

  alias SpheriumWebService.Permission

  def index(conn, _params) do
    permissions = Repo.all(Permission)

    render(conn, "index.json", permissions: permissions)
  end

  def show(conn, %{"id" => id}) do
    permission = Repo.get!(Permission, id)

    render(conn, "show.json", permission: permission)
  end

  def update(conn, %{"id" => id, "permission" => permission_params}) do
    permission = Repo.get!(Permission, id)
    changeset = Permission.changeset(permission, permission_params)

    case Repo.update(changeset) do
      {:ok, permission} ->
        conn
        |> render("show.json", permission: permission)
      {:error, changeset} ->
        conn
        |> render(SpheriumWebService.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
