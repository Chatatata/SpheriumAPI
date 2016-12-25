defmodule Spherium.TemporaryPasskeyView do
  use Spherium.Web, :view

  def render("one_time_code.json", %{one_time_code: one_time_code}) do
    %{user_id: one_time_code.user_id}
  end
end
