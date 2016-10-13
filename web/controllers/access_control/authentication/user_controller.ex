defmodule Spherium.UserController do
  use Spherium.Web, :controller

  import Ecto.Query, only: [where: 2]
  import Spherium.AuthenticationPlug
  import Spherium.AuthorizationPlug

  alias Spherium.User

  plug :authenticate_user when action in [:index, :show, :update, :delete]
  plug :authorize_user, [:all] when action in [:index, :delete]
  plug :authorize_user, [:all, :self] when action in [:show, :update]
  plug :apply_policy when not action in [:create]

  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    filters =
      Ecto.Changeset.cast(%User{}, conn.query_params, [], [:username, :email])
      |> Map.fetch(:changes)
      |> Kernel.elem(1)
      |> Map.to_list()

    users =
      User
      |> where(^filters)
      |> Repo.all()

    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spherium.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spherium.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    send_resp(conn, :no_content, "")
  end
end
