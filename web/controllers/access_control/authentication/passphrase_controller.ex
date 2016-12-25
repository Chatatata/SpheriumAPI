defmodule Spherium.PassphraseController do
  use Spherium.Web, :controller

  import Ecto.Changeset, only: [get_field: 2, put_change: 3]
  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias Spherium.Passphrase
  alias Spherium.PassphraseInvalidation
  alias Spherium.Passkey
  alias Spherium.Credentials
  alias Spherium.Attempt
  alias Spherium.User

  plug :authenticate_user when action in [:index, :show]
  plug :authorize_user, [:all, :self] when action in [:index, :show]
  plug :scrub_params, "code" when action in [:create]

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

  def create(conn, %{"code" => code}) do

  end
end
