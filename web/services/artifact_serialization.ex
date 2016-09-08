defmodule SpheriumWebService.ArtifactSerializer do
  use SpheriumWebService.Web, :service

  @behaviour Guardian.Serializer

  import SpheriumWebService.UserView, only: [render_private: 2]

  alias SpheriumWebService.User

  def for_token(user = %User{}), do: {:ok, render_private("user.json", %{user: user})}
  def for_token(_param), do: {:error, "Unknown resource type."}

  def from_token(subject), do: Poison.decode!(subject, as: %User{})
end
