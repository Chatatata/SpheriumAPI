defmodule Spherium.PassphraseInvalidationController do
  use Spherium.Web, :controller

  alias Spherium.Passphrase

  plug :authenticate_user
  plug :authorize_user

  def create(conn, %{"passphrase_id" => passphrase_id}) do
    query = from p in Passphrase,
            where: p.passkey == ^passphrase_id

    case Repo.update_all(query, set: [valid?: false]) do
      {1, nil} ->
        conn
        |> send_resp(:created, "Passphrase invalidated successfully.")
      {0, nil} ->
        conn
        |> send_resp(:not_found, "Passphrase not found.")
    end
  end
end
