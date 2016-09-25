defmodule SpheriumWebService.AttemptView do
  use SpheriumWebService.Web, :view
  use Timex

  def render("index.json", %{attempts: attempts}) do
    %{data: render_many(attempts, SpheriumWebService.AttemptView, "attempt.json")}
  end

  def render("show.json", %{attempt: attempt}) do
    %{data: render_one(attempt, SpheriumWebService.AttemptView, "attempt.json")}
  end

  def render("attempt.json", %{attempt: attempt}) do
    %{id: attempt.id,
      ip_addr: attempt.ip_addr,
      username: attempt.username,
      success: attempt.success}
  end
end
