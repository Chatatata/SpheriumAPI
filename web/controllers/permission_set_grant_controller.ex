defmodule SpheriumWebService.PermissionSetGrantController do
  use SpheriumWebService.Web, :controller

  alias SpheriumWebService.PermissionSetGrant

  def index(conn, _params) do
    permission_set_grants = Repo.all(PermissionSetGrant)
    render(conn, "index.json", permission_set_grants: permission_set_grants)
  end

  def create(conn, %{"permission_set_grant" => permission_set_grant_params}) do
    changeset = PermissionSetGrant.changeset(%PermissionSetGrant{}, permission_set_grant_params)

    case Repo.insert(changeset) do
      {:ok, permission_set_grant} ->
        conn
        |> put_status(:created)
        |> put_resp_header(:location, permission_set_grant_path(conn, :show, permission_set_grant))
        |> render("show.json", permission_set_grant: permission_set_grant)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SpheriumWebService.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    permission_set_grant = Repo.get!(PermissionSetGrant, id)
    render(conn, "show.json", permission_set_grant: permission_set_grant)
  end

  def update(conn, %{"id" => id, "permission_set_grant" => permission_set_grant_params}) do
    permission_set_grant = Repo.get!(PermissionSetGrant, id)
    changeset = PermissionSetGrant.changeset(permission_set_grant, permission_set_grant_params)

    case Repo.update(changeset) do
      {:ok, permission_set_grant} ->
        conn
        |> put_resp_header("location", permission_set_grant_path(conn, :show, permission_set_grant))
        |> render("show.json", permission_set_grant: permission_set_grant)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SpheriumWebService.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    permission_set_grant = Repo.get!(PermissionSetGrant, id)

    Repo.delete!(permission_set_grant)

    send_resp(conn, :no_content, "")
  end
end
