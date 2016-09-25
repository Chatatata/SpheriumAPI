defmodule Spherium.UserPasswordChangeView do
  use Spherium.Web, :view
  use Timex

  def render("user_password_change.json", %{user_id: user_id}) do
    %{result: "ok",
      user_id: user_id,
      date: Timex.now}
  end
end
