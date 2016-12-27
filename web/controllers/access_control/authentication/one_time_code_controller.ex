defmodule Spherium.OneTimeCodeController do
  use Spherium.Web, :controller

  import Ecto.Changeset, only: [get_field: 2, put_change: 3]
  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias Spherium.OneTimeCode
  alias Spherium.Code
  alias Spherium.Credentials
  alias Spherium.User
  alias Spherium.Attempt
  alias Spherium.Passphrase
  alias Spherium.PassphraseInvalidation
  alias Spherium.OneTimeCodeInvalidation
  alias Spherium.Unban

  plug :scrub_params, "credentials" when action in [:create]

  def create(conn, %{"credentials" => credentials}) do
    credentials_changeset = Credentials.changeset(%Credentials{}, credentials)

    ip_addr =
      conn.remote_ip
      |> Tuple.to_list
      |> Enum.join(".")

    if credentials_changeset.valid? do
      username = get_field(credentials_changeset, :username)
      password = get_field(credentials_changeset, :password)

      attempt_changeset = Attempt.changeset(%Attempt{}, %{username: username, ip_addr: ip_addr})

      case Repo.transaction(fn ->
        query = from u in User,
                where: u.username == ^username,
                select: u

        case Repo.one(query) do
          nil ->
            Repo.insert!(attempt_changeset)
            Repo.rollback(:invalid_password)
          user ->
            unless checkpw(password, user.password_digest), do: Repo.rollback(:invalid_password)

            query = from p in Passphrase,
                    left_join: pi in PassphraseInvalidation, on: pi.target_passphrase_id == p.id,
                    join: otc in OneTimeCode, on: p.one_time_code_id == otc.id,
                    where: otc.user_id == ^user.id and is_nil(pi.id)

            if Repo.aggregate(query, :count, :id) == 5, do: Repo.rollback(:max_passphrases_reached)

            query = from otc in OneTimeCode,
                    left_join: otci in OneTimeCodeInvalidation, on: otci.one_time_code_id == otc.id,
                    left_join: p in Passphrase, on: p.one_time_code_id == otc.id,
                    where: otc.user_id == ^user.id and
                           otc.inserted_at > ago(15, "minute") and
                           is_nil(otci.inserted_at) and
                           is_nil(p.inserted_at)

            if Repo.aggregate(query, :count, :id) == 2, do: Repo.rollback(:otc_quota_reached)

            one_time_code_changeset =
              OneTimeCode.changeset(
                %OneTimeCode{},
                %{user_id: user.id,
                  code: Code.generate(),
                  device: get_field(credentials_changeset, :device),
                  user_agent: get_field(credentials_changeset, :user_agent)}
              )

            Repo.insert!(one_time_code_changeset)
        end
      end) do
        {:ok, one_time_code} ->
          attempt_changeset
          |> put_change(:success, true)
          |> Repo.insert!()

          conn
          |> put_status(:created)
          |> put_resp_content_type("application/json")
          |> render("one_time_code.json", one_time_code: one_time_code)
        {:error, :max_passphrases_reached} ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(:conflict, "Maximum number of passphrases available is reached (5).")
        {:error, :otc_quota_reached} ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(:too_many_requests, "OTC quota per 15 minutes is reached (2).")
        {:error, :invalid_password} ->
          attempt_changeset
          |> Repo.insert!()

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(:forbidden, "Invalid username/password combination.")
      end
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Spherium.ChangesetView, "error.json", changeset: credentials_changeset)
    end
  end
end
