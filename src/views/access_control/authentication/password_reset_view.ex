defmodule Spherium.PasswordResetView do
  use Spherium.Web, :view

  def render("index.json", %{password_resets: password_resets}) do
    %{data: render_many(password_resets, Spherium.PasswordResetView, "password_reset.json")}
  end

  def render("show.json", %{password_reset: password_reset}) do
    %{data: render_one(password_reset, Spherium.PasswordResetView, "password_reset.json")}
  end

  def render("password_reset.json", %{password_reset: password_reset}) do
    %{id: password_reset.id,
      user_id: password_reset.user_id}
  end
end
