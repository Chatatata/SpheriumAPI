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
    ip_addr =
      conn.remote_ip
      |> Tuple.to_list()
      |> Enum.join(".")

    changeset =
      PassphraseInvalidation.changeset(
        %PassphraseInvalidation{},
        %{passphrase_id: conn.assigns[:passphrase_id],
          target_passphrase_id: target_passphrase_id,
          ip_addr: ip_addr}
      )

    try do
      {:ok, passphrase_invalidation} =
        Repo.transaction(fn ->
          if conn.assigns[:permission_type] == :self do
            passphrase = Repo.get!(Passphrase, target_passphrase_id)

            validate_possession conn, passphrase
          end

          Repo.insert!(changeset)
        end)

      conn
      |> put_status(:created)
      |> render("show.json", passphrase_invalidation: passphrase_invalidation)
    rescue
      ice in Ecto.InvalidChangesetError ->
        case List.keyfind(ice.changeset.errors, :target_passphrase_id, 0) do
          {:target_passphrase_id, {"does not exist", []}} ->
            raise Ecto.NoResultsError, queryable: Passphrase
          _ ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(Spherium.ChangesetView, "error.json", changeset: ice.changeset)
        end
    end
  end
end
