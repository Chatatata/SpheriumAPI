defmodule Spherium.AuthenticationController do
  use Spherium.Web, :controller

  import Ecto.Changeset, only: [get_field: 2]
  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias Spherium.Credentials
  alias Spherium.Attempt
  alias Spherium.Passphrase
  alias Spherium.PassphraseInvalidation
  alias Spherium.OneTimeCode
  alias Spherium.OneTimeCodeInvalidation
  alias Spherium.Code
  alias Spherium.Passkey
  alias Spherium.User

  plug :scrub_params, "credentials"

  def create(conn, %{"credentials" => credentials}) do
    credentials_changeset = Credentials.changeset(%Credentials{}, credentials)
    ip_addr = get_remote_ip_string(conn)

    if credentials_changeset.valid? do
      username = get_field(credentials_changeset, :username)

      result =
        Repo.transaction(fn ->
          fetch_user_with_username(username)
          |> Map.put(:device, get_field(credentials_changeset, :device))
          |> Map.put(:user_agent, get_field(credentials_changeset, :user_agent))
          |> validate_credentials(get_field(credentials_changeset, :password))
          |> check_passphrase_quota()
          |> apply_authentication_scheme()
        end)

      persist_attempt(result, username, ip_addr)
      respond(conn, result)
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Spherium.ChangesetView, "error.json", changeset: credentials_changeset)
    end
  end

  defp get_remote_ip_string(conn) do
    conn.remote_ip
    |> Tuple.to_list
    |> Enum.join(".")
  end

  defp fetch_user_with_username(username) do
    case Repo.get_by(User, username: username) do
      nil ->
        Repo.rollback(:invalid_password)
      user ->
        user
    end
  end

  defp validate_credentials(user, password) do
    unless checkpw(password, user.password_digest) do
      Repo.rollback(:invalid_password)
    else
      user
    end
  end

  defp check_passphrase_quota(user) do
    # CAVEAT: This query needs to work in a read committed transaction in order to prevent race conditions.
    query = from p in Passphrase,
            left_join: pi in PassphraseInvalidation, on: pi.target_passphrase_id == p.id,
            where: p.user_id == ^user.id and
                   is_nil(pi.inserted_at) and
                   p.inserted_at > fragment("(SELECT
                                               CASE
                                                 WHEN max(inserted_at) IS NULL THEN to_timestamp(0)
                                                 ELSE max(inserted_at)
                                               END
                                             FROM password_resets
                                             WHERE user_id = ?)", ^user.id),
            select: p

    if Repo.aggregate(query, :count, :id) >= 5 do
      Repo.rollback(:max_passphrases_reached)
    else
      user
    end
  end

  @doc """
  Performs concrete authentication instantiation on user with corresponding authentication
  scheme.
  """
  def apply_authentication_scheme(user) do
    apply_authentication_scheme(user, user.authentication_scheme)
  end

  @doc """
  Performs concrete authentication instantiation on user with insecure authentication scheme.
  """
  def apply_authentication_scheme(user, :insecure) do
    passphrase_changeset =
      Passphrase.changeset(
        %Passphrase{},
        %{passkey: Passkey.generate(),
          user_id: user.id,
          device: user.device,
          user_agent: user.user_agent}
      )

    {:passphrase, Repo.insert!(passphrase_changeset)}
  end

  @doc """
  Performs concrete authentication instantiation on user with two-factor authentication over
  one-time-code scheme.
  """
  def apply_authentication_scheme(user, :two_factor_over_otc) do
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
          device: user.device,
          user_agent: user.user_agent}
      )

    {:one_time_code, Repo.insert!(one_time_code_changeset)}
  end

  @doc """
  Performs concrete authentication instantiation on user with two-factor authentication over
  time-based-code scheme.
  """
  def apply_authentication_scheme(_user, :two_factor_over_tbc) do
    Repo.rollback(:tbc_not_available)
  end

  defp persist_attempt(result, username, ip_addr) do
    changeset = Attempt.changeset(%Attempt{},
                                  %{username: username,
                                    success: result != {:error, :invalid_password},
                                    ip_addr: ip_addr})

    Repo.insert!(changeset)
  end

  defp respond(conn, {:ok, element}) do
    respond_with_success(conn, elem(element, 0), elem(element, 1))
  end

  defp respond(conn, {:error, element}) do
    respond_with_failure(conn, element)
  end

  defp respond_with_success(conn, :passphrase, passphrase) do
    conn
    |> put_status(:created)
    |> render(Spherium.AuthenticationResultView,
              "show.insecure.json",
              passphrase: passphrase)
  end

  defp respond_with_success(conn, :one_time_code, one_time_code) do
    conn
    |> put_status(:created)
    |> render(Spherium.AuthenticationResultView,
              "show.two_factor_over_otc.json",
              one_time_code: one_time_code)
  end

  defp respond_with_failure(conn, :max_passphrases_reached) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(:conflict, "Maximum number of passphrases available is reached (5).")
  end

  defp respond_with_failure(conn, :otc_quota_reached) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(:too_many_requests, "OTC quota per 15 minutes is reached (2).")
  end

  defp respond_with_failure(conn, :invalid_password) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(:forbidden, "Invalid username/password combination.")
  end

  defp respond_with_failure(conn, :tbc_not_available) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(:not_implemented, "TBC is not available currently.")
  end
end
