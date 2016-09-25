defmodule Spherium.TokenView do
  use Spherium.Web, :view

  def render("show.json", %{token: token}) do
    %{data: render_one(token, Spherium.TokenView, "token.json")}
  end

  def render("token.json", %{token: token}) do
    %{jwt: token.jwt,
      exp: token.exp,
      timestamp: token.timestamp}
  end
end
