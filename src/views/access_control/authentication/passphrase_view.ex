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
    %{id: passphrase.id,
      user_id: passphrase.user_id,
      device: passphrase.device,
      user_agent: passphrase.user_agent,
      inserted_at: passphrase.inserted_at}
  end

  def render("passphrase.private.json", %{passphrase: passphrase}) do
    %{id: passphrase.id,
      passkey: passphrase.passkey,
      user_id: passphrase.user_id,
      device: passphrase.device,
      user_agent: passphrase.user_agent,
      inserted_at: passphrase.inserted_at}
  end

  def render("passphrase.jwt.json", %{passphrase: passphrase}) do
    %{passphrase_id: passphrase.id,
      user_id: passphrase.user_id,
      device: passphrase.device,
      user_agent: passphrase.user_agent,
      inserted_at: passphrase.inserted_at}
  end
end
