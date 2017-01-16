defmodule Spherium.PassphraseView do
  use Spherium.Web, :view

  def render("index.json", %{passphrases: passphrases}) do
    %{data: render_many(passphrases, Spherium.PassphraseView, "passphrase.json")}
  end

  def render("show.json", %{passphrase: passphrase}) do
    %{data: render_one(passphrase, Spherium.PassphraseView, "passphrase.json")}
  end

  def render("show.private.json", %{passphrase: passphrase}) do
    %{data: render_one(passphrase, Spherium.PassphraseView, "passphrase.private.json")}
  end

  def render("passphrase.json", %{passphrase: passphrase}) do
    %{passphrase_id: passphrase.id}
  end

  def render("passphrase.private.json", %{passphrase: passphrase}) do
    %{passphrase_id: passphrase.id,
      passkey: passphrase.passkey}
  end
end
