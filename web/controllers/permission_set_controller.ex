defmodule SpheriumWebService.PermissionSetController do
  use SpheriumWebService.Web, :controller

  alias SpheriumWebService.PermissionSet

  def index(conn, _params) do
    permission_sets = Repo.all(PermissionSet) |> Repo.preload(:permissions)
    render conn, "index.json", permission_sets: permission_sets
  end

  def create(conn, %{"permission_set" => permission_set_params}) do
    # TODO: Property user_id should not be provided in permission_set.
    changeset = PermissionSet.changeset(%PermissionSet{}, permission_set_params)

    case Repo.insert(changeset) do
      {:ok, permission_set} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", permission_set_path(conn, :show, permission_set))
        |> render("show.json", permission_set: permission_set)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SpheriumWebService.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    permission_set = Repo.get!(PermissionSet, id) |> Repo.preload(:permissions)
    render conn, "show.json", permission_set: permission_set
  end

  def update(conn, %{"id" => id, "permission_set" => permission_set_params}) do
    # TODO: Should not allow to change user_id.
    permission_set = Repo.get!(PermissionSet, id)
    changeset = PermissionSet.changeset(permission_set, permission_set_params)

    case Repo.update(changeset) do
      {:ok, permission_set} ->
        conn
        |> render("show.json", permission_set: permission_set)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SpheriumWebService.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    permission_set = Repo.get!(PermissionSet, id)

    Repo.delete!(permission_set)

    send_resp(conn, :no_content, "")
  end
end
