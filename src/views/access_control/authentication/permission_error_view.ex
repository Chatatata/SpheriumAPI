defmodule Spherium.PermissionErrorView do
  use Spherium.Web, :view

  def render("unauthorized.json", _params) do
    %{error: "You are unauthorized to see this entity."}
  end
end
