defmodule Spherium.AttemptController do
  use Spherium.Web, :controller

  alias Spherium.Attempt

  plug :authenticate_user
  plug :authorize_user

  def index(conn, _params) do
    attempts = Repo.all(Attempt)
    render(conn, "index.json", attempts: attempts)
  end

  def show(conn, %{"id" => id}) do
    attempt = Repo.get!(Attempt, id)
    render(conn, "show.json", attempt: attempt)
  end
end
