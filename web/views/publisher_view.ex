defmodule SpheriumWebService.PublisherView do
  use SpheriumWebService.Web, :view

  def render("index.json", %{publishers: publishers}) do
    %{data: render_many(publishers, SpheriumWebService.PublisherView, "publisher.json")}
  end

  def render("show.json", %{publisher: publisher}) do
    %{data: render_one(publisher, SpheriumWebService.PublisherView, "publisher.json")}
  end

  def render("publisher.json", %{publisher: publisher}) do
    %{id: publisher.id,
      user_id: publisher.user_id,
      name: publisher.name,
      image: publisher.image,
      description: publisher.description}
  end
end
