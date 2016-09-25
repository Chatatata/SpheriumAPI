defmodule Spherium.AttemptViewTest do
  use Spherium.ConnCase, async: true

  import Phoenix.View

  alias Spherium.Factory

  test "renders auth attempt" do
    attempt = Factory.insert(:attempt)

    assert render(Spherium.AttemptView,
                  "attempt.json",
                  %{attempt: attempt}) ==
                  %{id: attempt.id,
                    ip_addr: attempt.ip_addr,
                    username: attempt.username,
                    success: attempt.success}
  end
end
