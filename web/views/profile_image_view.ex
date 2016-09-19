defmodule SpheriumWebService.ProfileImageView do
  use SpheriumWebService.Web, :view

  def render("show.json", %{profile_image: profile_image}) do
    %{data: render_one(profile_image, SpheriumWebService.ProfileImageView, "profile_image.json")}
  end

  def render("profile_image.json", %{profile_image: profile_image}) do
    %{id: profile_image.id,
      user_id: profile_image.user_id,
      data: profile_image.data}
  end
end
