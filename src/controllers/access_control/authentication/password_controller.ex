defmodule Spherium.PasswordController do
  use Spherium.Web, :controller

  alias Spherium.User

  plug :authenticate_user
  plug :authorize_user, [:all]
  plug :scrub_params, "password"
  plug :put_view, Spherium.PasswordChangeView

  def update(conn, %{"user_id" => user_id, "password" => password}) do
    user = Repo.get!(User, user_id)
    changeset = User.changeset(user, %{password: password})

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> render("password_change.json", user_id: user_id)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spherium.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
