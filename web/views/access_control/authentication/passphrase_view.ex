defmodule Spherium.PassphraseView do
  use Spherium.Web, :view

  def render("show.json", %{passphrase: passphrase}) do
    %{data: render_one(passphrase, Spherium.PassphraseView, "passphrase.json")}
  end

  def render("passphrase.json", %{passphrase: passphrase}) do
    %{passkey: passphrase.passkey,
      device: passphrase.device,
      user_agent: passphrase.user_agent}
  end
end
