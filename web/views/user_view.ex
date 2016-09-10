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
      email: user.email,
      scope: user.scope,
      created_at: Ecto.DateTime.to_iso8601(user.inserted_at)}
  end

  def render_private("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username,
      email: user.email,
      scope: user.scope,
      created_at: Ecto.DateTime.to_iso8601(user.inserted_at)}
  end
end
