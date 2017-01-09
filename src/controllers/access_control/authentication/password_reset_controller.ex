defmodule Spherium.PasswordResetController do
  @moduledoc """
  Initiates a password reset on target user.

  The state of a users password reset is determined by making a comparison between
  associated password reset entry and earliest active passphrase.

  This controller inserts a password reset object to the persistent storage.
  """
  use Spherium.Web, :controller

  alias Spherium.PasswordReset

  def index(conn, %{"user_id" => user_id}) do
    query = from p in PasswordReset,
            select: p,
            where: p.user_id == ^user_id

    password_resets = Repo.all(query)
    render(conn, "index.json", password_resets: password_resets)
  end

  def create(conn, %{"user_id" => user_id}) do
    changeset = PasswordReset.changeset(%PasswordReset{}, %{user_id: user_id})

    case Repo.insert(changeset) do
      {:ok, password_reset} ->
        conn
        |> put_status(:created)
        |> render("show.json", password_reset: password_reset)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spherium.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
