defmodule SpheriumWebService.AuthAttemptViewTest do
  use SpheriumWebService.ConnCase, async: true

  import Phoenix.View

  alias SpheriumWebService.Factory

  test "renders auth attempt" do
    auth_attempt = Factory.insert(:auth_attempt)

    assert render(SpheriumWebService.AuthAttemptView,
                  "auth_attempt.json",
                  %{auth_attempt: auth_attempt}) ==
                  %{id: auth_attempt.id,
                    ip_addr: auth_attempt.ip_addr,
                    username: auth_attempt.username,
                    success: auth_attempt.success}
  end

  test "renders artifacts" do
    user = Factory.insert(:user)
    artifacts = %{user: user,
                  jwt: "jwt",
                  exp: "12345123"}

    view = render(SpheriumWebService.AuthAttemptView, "artifacts.json", %{artifacts: artifacts}).data

    assert view.user
    assert view.jwt =~ "jwt"
    assert view.exp =~ "12345123"
    assert view.date
  end
end
