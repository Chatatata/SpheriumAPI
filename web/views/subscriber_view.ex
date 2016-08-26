defmodule SpheriumWebService.SubscriberView do
  use SpheriumWebService.Web, :view

  def render("index.json", %{subscribers: subscribers}) do
    %{data: render_many(subscribers, SpheriumWebService.SubscriberView, "subscriber.json")}
  end

  def render("show.json", %{subscriber: subscriber}) do
    %{data: render_one(subscriber, SpheriumWebService.SubscriberView, "subscriber.json")}
  end

  def render("subscriber.json", %{subscriber: subscriber}) do
    %{id: subscriber.id,
      address: subscriber.address}
  end
end
