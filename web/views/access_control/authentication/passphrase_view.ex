defmodule Spherium.PassphraseView do
  use Spherium.Web, :view

  def render("show.json", %{passphrase: passphrase}) do
    %{data: render_one(passphrase, Spherium.PassphraseView, "passphrase.json")}
  end

  def render("passphrase.json", %{passphrase: passphrase}) do
    %{passkey: passphrase.passkey,
      device: passphrase.device,
      user_agent: passphrase.user_agent,
      inserted_at: passphrase.inserted_at}
  end

  def render("passphrase.min.json", %{passphrase: passphrase}) do
    %{passphrase_id: passphrase.id,
      passkey: passphrase.passkey}
  end
end
