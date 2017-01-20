defmodule Spherium.AuthenticationResultView do
  use Spherium.Web, :view

  def render("show.insecure_authentication_handle.json",
             %{insecure_authentication_handle: insecure_authentication_handle}) do
    insecure_authentication_handle_view =
      render_one(insecure_authentication_handle,
                 Spherium.InsecureAuthenticationHandleView,
                 "insecure_authentication_handle.json")
      |> Map.merge(%{"authentication_scheme" => "insecure"})

    %{data: insecure_authentication_handle_view}
  end

  def render("show.two_factor_over_otc.json", %{one_time_code: one_time_code}) do
    one_time_code_view =
      render_one(one_time_code, Spherium.OneTimeCodeView, "one_time_code.json")
      |> Map.merge(%{"authentication_scheme" => "two_factor_over_otc"})

    %{data: one_time_code_view}
  end
end
