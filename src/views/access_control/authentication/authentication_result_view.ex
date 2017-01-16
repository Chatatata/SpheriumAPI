defmodule Spherium.AuthenticationResultView do
  use Spherium.Web, :view

  def render("show.insecure.json", %{passphrase: passphrase}) do
    passphrase_view =
      render_one(passphrase, Spherium.PassphraseView, "passphrase.private.json")
      |> Map.merge(%{"authentication_scheme" => "insecure"})

    %{data: passphrase_view}
  end

  def render("show.two_factor_over_otc.json", %{one_time_code: one_time_code}) do
    one_time_code_view =
      render_one(one_time_code, Spherium.OneTimeCodeView, "one_time_code.json")
      |> Map.merge(%{"authentication_scheme" => "two_factor_over_otc"})

    %{data: one_time_code_view}
  end

end
