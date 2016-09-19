defmodule SpheriumWebService.AuthAttemptView do
  use SpheriumWebService.Web, :view
  use Timex

  alias SpheriumWebService.UserView

  def render("index.json", %{auth_attempts: auth_attempts}) do
    %{data: render_many(auth_attempts, SpheriumWebService.AuthAttemptView, "auth_attempt.json")}
  end

  def render("show.json", %{auth_attempt: auth_attempt}) do
    %{data: render_one(auth_attempt, SpheriumWebService.AuthAttemptView, "auth_attempt.json")}
  end

  def render("auth_attempt.json", %{auth_attempt: auth_attempt}) do
    %{id: auth_attempt.id,
      ip_addr: auth_attempt.ip_addr,
      username: auth_attempt.username,
      success: auth_attempt.success}
  end

  def render("artifacts.json", %{artifacts: artifacts}) do
    %{data: %{user: UserView.render_private("user.json", %{user: artifacts.user}),
              jwt: artifacts.jwt,
              exp: artifacts.exp,
              date: Timex.now}}
  end
end
