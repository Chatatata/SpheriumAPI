defmodule SpheriumWebService.ProfileImageController do
  use SpheriumWebService.Web, :controller

  alias SpheriumWebService.ProfileImage
  alias SpheriumWebService.User

  plug :authenticate_user
  plug :authorize_user
  plug :scrub_params, "profile_image" when action in [:create, :update]

  def create(conn, %{"user_id" => user_id, "profile_image" => profile_image_params}) do
    changeset
       = Repo.get!(User, user_id)
       |> Repo.preload([:image])
       |> build_assoc(:image)
       |> ProfileImage.changeset(profile_image_params)

    case Repo.insert(changeset) do
      {:ok, profile_image} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_profile_image_path(conn, :show, user_id))
        |> render("show.json", profile_image: profile_image)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SpheriumWebService.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"user_id" => user_id}) do
    profile_image = Repo.one!(from image in ProfileImage, where: image.user_id == ^user_id)
    render(conn, "show.json", profile_image: profile_image)
  end

  def update(conn, %{"user_id" => user_id, "profile_image" => profile_image_params}) do
     changeset
        = Repo.one!(from image in ProfileImage, where: image.user_id == ^user_id)
        |> Repo.preload(:user)
        |> ProfileImage.changeset(profile_image_params)

    case Repo.update(changeset) do
      {:ok, profile_image} ->
        render(conn, "show.json", profile_image: profile_image)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SpheriumWebService.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"user_id" => user_id}) do
    profile_image = Repo.one!(from image in ProfileImage, where: image.user_id == ^user_id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(profile_image)

    send_resp(conn, :no_content, "")
  end
end
