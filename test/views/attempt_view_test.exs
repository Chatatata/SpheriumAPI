defmodule SpheriumWebService.AttemptViewTest do
  use SpheriumWebService.ConnCase, async: true

  import Phoenix.View

  alias SpheriumWebService.Factory

  test "renders auth attempt" do
    attempt = Factory.insert(:attempt)

    assert render(SpheriumWebService.AttemptView,
                  "attempt.json",
                  %{attempt: attempt}) ==
                  %{id: attempt.id,
                    ip_addr: attempt.ip_addr,
                    username: attempt.username,
                    success: attempt.success}
  end
end
