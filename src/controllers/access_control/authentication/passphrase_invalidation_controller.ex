defmodule Spherium.PassphraseInvalidationController do
  use Spherium.Web, :controller

  alias Spherium.Passphrase
  alias Spherium.PassphraseInvalidation

  plug :authenticate_user
  plug :authorize_user, [:all, :self]
  plug :scrub_params, "passphrase_invalidation" when action in [:create]

  def create(conn,
             %{"passphrase_invalidation" =>
               %{"target_passphrase_id" => target_passphrase_id}}) do
    # Check if user owns target passphrase
    ip_addr =
      conn.remote_ip
      |> Tuple.to_list()
      |> Enum.join(".")

    changeset = PassphraseInvalidation.changeset(%PassphraseInvalidation{},
                                                 %{passphrase_id: conn.assigns[:passphrase_id],
                                                   target_passphrase_id: target_passphrase_id,
                                                   ip_addr: ip_addr})

    try do
      case Repo.transaction(fn ->
        if conn.assigns[:permission_type] == :self do
          passphrase = Repo.get!(Passphrase, target_passphrase_id)

          if passphrase.user_id == conn.assigns[:user].id, do: Repo.rollback(:unauthorized)
        end

        Repo.insert!(changeset)
      end) do
        {:ok, passphrase_invalidation} ->
          conn
          |> put_status(:created)
          |> render("show.json", passphrase_invalidation: passphrase_invalidation)
        {:error, :unauthorized} ->
          raise InsufficientScopeError
      end
    rescue
      Ecto.NoResultsError ->
        conn
        |> send_resp(:not_found, "")
      ice in Ecto.InvalidChangesetError ->
        case List.keyfind(ice.changeset.errors, :target_passphrase_id, 0) do
          {:target_passphrase_id, {"does not exist", []}} ->
            conn
            |> send_resp(:not_found, "")
          _ ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(Spherium.ChangesetView, "error.json", changeset: ice.changeset)
        end
    end
  end
end
