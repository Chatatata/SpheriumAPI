defmodule Spherium.PassphraseController do
  use Spherium.Web, :controller

  import Ecto.Changeset, only: [get_field: 2]

  alias Spherium.Passphrase
  alias Spherium.PassphraseGenerationAttempt
  alias Spherium.User
  alias Spherium.OneTimeCode
  alias Spherium.OneTimeCodeInvalidation
  alias Spherium.Passkey

  plug :authenticate_user when action in [:index, :show]
  plug :authorize_user, [:all, :self] when action in [:index, :show]
  plug :scrub_params, "passphrase_generation_attempt" when action in [:create]

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

  def create(conn, %{"passphrase_generation_attempt" => passphrase_generation_attempt}) do

    passphrase_generation_attempt_changeset =
      PassphraseGenerationAttempt.changeset(
        %PassphraseGenerationAttempt{},
        passphrase_generation_attempt
      )

    if passphrase_generation_attempt_changeset.valid? do
      user_id = get_field(passphrase_generation_attempt_changeset, :user_id)
      code = get_field(passphrase_generation_attempt_changeset, :code)

      case Repo.transaction(fn ->
        query = from u in User,
                join: otc in OneTimeCode, on: otc.user_id == u.id,
                left_join: otci in OneTimeCodeInvalidation, on: otc.id == otci.one_time_code_id,
                left_join: p in Passphrase, on: otc.id == p.one_time_code_id,
                where: u.id == ^user_id and
                       is_nil(otci.inserted_at) and
                       is_nil(p.inserted_at) and
                       otc.inserted_at == fragment("(SELECT max(inserted_at)
                                                    FROM one_time_codes
                                                    WHERE user_id = ?)", ^user_id) and
                       otc.inserted_at > ago(3, "minute"),
                select: otc

        case Repo.one(query) do
          nil -> Repo.rollback(:not_found)
          otc ->
            if otc.code == code do
              passphrase_changeset =
                Passphrase.changeset(
                  %Passphrase{},
                  %{passkey: Passkey.generate(),
                    one_time_code_id: otc.id}
                )

              {:ok, Repo.insert!(passphrase_changeset)}
            else
              one_time_code_invalidation_changeset =
                OneTimeCodeInvalidation.changeset(
                  %OneTimeCodeInvalidation{},
                  %{one_time_code_id: otc.id}
                )

              {:error, Repo.insert!(one_time_code_invalidation_changeset)}
            end
        end
      end) do
        {:ok, {:ok, passphrase}} ->
          conn
          |> put_status(:created)
          |> render("show.private.json", passphrase: passphrase)
        {:ok, {:error, _one_time_code_invalidation}} ->
          conn
          |> put_resp_content_type("text/plain")
          |> send_resp(:not_found, "Pair not found.")
        {:error, :not_found} ->
          conn
          |> put_resp_content_type("text/plain")
          |> send_resp(:not_found, "Pair not found.")
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Spherium.ChangesetView,
                    "error.json",
                    changeset: changeset)
      end
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Spherium.ChangesetView,
                "error.json",
                changeset: passphrase_generation_attempt_changeset)
    end
  end
end
