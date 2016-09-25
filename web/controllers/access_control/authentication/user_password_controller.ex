defmodule SpheriumWebService.UserPasswordController do
  use SpheriumWebService.Web, :controller

  alias SpheriumWebService.User

  plug :authenticate_user
  plug :authorize_user
  plug :scrub_params, "password" when action in [:update]
  plug :put_view, SpheriumWebService.UserPasswordChangeView

  # TODO: Forgot password
  # def create(conn, %{""})

  def update(conn, %{"user_id" => user_id, "password" => password}) do
    user = Repo.get!(User, user_id)
    changeset = User.changeset(user, %{password: password})

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> render("user_password_change.json", user_id: user_id)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SpheriumWebService.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
