defmodule SpheriumWebService.SubscriberController do
  use SpheriumWebService.Web, :controller

  alias SpheriumWebService.Subscriber

  def index(conn, _params) do
    subscribers = Repo.all(Subscriber)
    render(conn, "index.json", subscribers: subscribers)
  end

  def create(conn, %{"subscriber" => subscriber_params}) do
    changeset = Subscriber.changeset(%Subscriber{}, subscriber_params)

    case Repo.insert(changeset) do
      {:ok, subscriber} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", subscriber_path(conn, :show, subscriber))
        |> render("show.json", subscriber: subscriber)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SpheriumWebService.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    subscriber = Repo.get!(Subscriber, id)
    render(conn, "show.json", subscriber: subscriber)
  end

  def update(conn, %{"id" => id, "subscriber" => subscriber_params}) do
    subscriber = Repo.get!(Subscriber, id)
    changeset = Subscriber.changeset(subscriber, subscriber_params)

    case Repo.update(changeset) do
      {:ok, subscriber} ->
        render(conn, "show.json", subscriber: subscriber)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SpheriumWebService.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    subscriber = Repo.get!(Subscriber, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(subscriber)

    send_resp(conn, :no_content, "")
  end
end
