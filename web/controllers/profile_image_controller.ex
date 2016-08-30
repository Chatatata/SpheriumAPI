defmodule SpheriumWebService.ProfileImageController do
  use SpheriumWebService.Web, :controller

  alias SpheriumWebService.ProfileImage

  def create(conn, %{"user_id" => user_id, "profile_image" => profile_image_params}) do
    changeset = ProfileImage.changeset(%ProfileImage{user_id: user_id}, profile_image_params)

    case Repo.insert(changeset) do
      {:ok, profile_image} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_profile_image_path(conn, :show, user_id, profile_image))
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
     profile_image = Repo.one!(from image in ProfileImage, where: image.user_id == ^user_id)
     changeset = ProfileImage.changeset(profile_image, profile_image_params)

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
