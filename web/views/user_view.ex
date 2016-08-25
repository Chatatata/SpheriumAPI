defmodule SpheriumWebService.UserView do
  use SpheriumWebService.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, SpheriumWebService.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, SpheriumWebService.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username,
      password_digest: user.password_digest,
      email: user.email,
      scope: user.scope,
      activation_key: user.activation_key}
  end
end
