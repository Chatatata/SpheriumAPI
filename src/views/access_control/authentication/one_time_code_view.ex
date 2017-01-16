defmodule Spherium.OneTimeCodeView do
  use Spherium.Web, :view

  def render("show.json", %{one_time_code: one_time_code}) do
    %{data: render_one(one_time_code, Spherium.OneTimeCodeView, "one_time_code.json")}
  end

  def render("one_time_code.json", %{one_time_code: one_time_code}) do
    %{user_id: one_time_code.user_id}
  end
end
