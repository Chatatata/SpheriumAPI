defmodule Spherium.PermissionSetController do
  use Spherium.Web, :controller

  alias Spherium.PermissionSet

  plug :authenticate_user
  plug :authorize_user, [:all]
  plug :scrub_params, "permission_set" when action in [:create, :update]

  def index(conn, _params) do
    permission_sets = Repo.all(PermissionSet) |> Repo.preload(:permissions)
    render conn, "index.json", permission_sets: permission_sets
  end

  def create(conn, %{"permission_set" => permission_set_params}) do
    permission_set_params = Map.merge(permission_set_params, %{"user_id" => conn.assigns[:user].id})
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
        |> render(Spherium.ChangesetView, "error.json", changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    permission_set = Repo.get!(PermissionSet, id) |> Repo.preload(:permissions)
    render conn, "show.json", permission_set: permission_set
  end

  def update(conn, %{"id" => id, "permission_set" => permission_set_params}) do
    unless Map.has_key?(permission_set_params, "user_id") do
      query = from ps in PermissionSet,
              preload: [:permissions]

      permission_set = Repo.get!(query, id)
      changeset = PermissionSet.changeset(permission_set, permission_set_params)

      case Repo.update(changeset) do
        {:ok, permission_set} ->
          conn
          |> render("show.json", permission_set: permission_set)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Spherium.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> send_resp(:unprocessable_entity, "User identifier field is not allowed.")
    end
  end

  def delete(conn, %{"id" => id}) do
    permission_set = Repo.get!(PermissionSet, id)

    Repo.delete!(permission_set)

    send_resp(conn, :no_content, "")
  end
end
