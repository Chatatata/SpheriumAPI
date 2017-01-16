defmodule Spherium.PassphraseController do
  use Spherium.Web, :controller

  alias Spherium.Passphrase

  plug :authenticate_user
  plug :authorize_user, [:all, :self]

  def index(conn, _params) do
    passphrases = Repo.all(Passphrase)

    render conn, "index.json", passphrases: passphrases
  end

  def show(conn, %{"id" => id}) do
    passphrase = Repo.get!(Passphrase, id)

    unless conn.assigns[:permission_type] == :one and
           passphrase.user_id == conn.assigns[:user].id, do: raise InsufficientScopeError

    render conn, "show.json", passphrase: passphrase
  end
end
