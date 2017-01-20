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
  alias Spherium.OneTimeCodeSubmission
  alias Spherium.Code
  alias Spherium.Passkey
  alias Spherium.User
  alias Spherium.InsecureAuthenticationSubmission
  alias Spherium.InsecureAuthenticationHandle
  alias Spherium.DeviceInformation

  def create(conn, %{"credentials" => credentials}) do
    credentials_changeset = Credentials.changeset(%Credentials{}, credentials)
    ip_addr = get_remote_ip_string(conn)

    if credentials_changeset.valid? do
      username = get_field(credentials_changeset, :username)

      result =
        Repo.transaction(fn ->
          fetch_user_with_username(username)
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

  def create(conn,
             %{"insecure_authentication_submission" => insecure_authentication_submission,
               "device_information" => device_information}) do
    submission_changeset =
      InsecureAuthenticationSubmission.changeset(%InsecureAuthenticationSubmission{},
                                                 insecure_authentication_submission)

    device_information_changeset =
      DeviceInformation.changeset(%DeviceInformation{},
                                  device_information)

    cond do
      submission_changeset.valid? and device_information_changeset.valid? ->
        passkey = get_field(submission_changeset, :passkey)
        user_id = get_field(submission_changeset, :user_id)

        result = Repo.transaction(fn -> find_handle_pair(passkey, user_id) end)

        respond(conn, result)
      not submission_changeset.valid? ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spherium.ChangesetView, "error.json", changeset: submission_changeset)
      not device_information_changeset.valid? ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spherium.ChangesetView, "error.json", changeset: device_information_changeset)
    end
  end

  def create(conn, %{"one_time_code_submission" => one_time_code_submission,
                     "device_information" => device_information}) do
    one_time_code_submission_changeset =
      OneTimeCodeSubmission.changeset(
        %OneTimeCodeSubmission{},
        one_time_code_submission
      )

    device_information_changeset =
      DeviceInformation.changeset(%DeviceInformation{},
                                  device_information)

    cond do
      one_time_code_submission_changeset.valid? and device_information_changeset.valid? ->
        user_id = get_field(one_time_code_submission_changeset, :user_id)
        code = get_field(one_time_code_submission_changeset, :code)

        result = Repo.transaction(fn -> challenge_user_with_otc(user_id, code) end)

        respond(conn, result)
      not one_time_code_submission_changeset.valid? ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spherium.ChangesetView,
                  "error.json",
                  changeset: one_time_code_submission_changeset)
      not device_information_changeset.valid? ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spherium.ChangesetView,
                  "error.json",
                  changeset: device_information_changeset)
    end
  end

  defp find_handle_pair(passkey, user_id) do
    query = from iah in InsecureAuthenticationHandle,
            where: iah.user_id == ^user_id and
                   iah.passkey == ^passkey and
                   iah.inserted_at == fragment("(SELECT max(inserted_at)
                                                 FROM insecure_authentication_handles
                                                 WHERE user_id = ?)", ^user_id) and
                   iah.inserted_at > ago(3, "minute"),
            select: iah

    if Repo.aggregate(query, :count, :id) do
      passphrase_changeset =
        Passphrase.changeset(
          %Passphrase{},
          %{passkey: Passkey.generate(),
            user_id: user_id}
        )

      {:passphrase, Repo.insert!(passphrase_changeset)}
    else
      Repo.rollback(:not_found)
    end
  end

  defp challenge_user_with_otc(user_id, code) do
    query = from u in User,
            join: otc in OneTimeCode, on: otc.user_id == u.id,
            left_join: otci in OneTimeCodeInvalidation, on: otc.id == otci.one_time_code_id,
            left_join: p in Passphrase, on: p.inserted_at > otc.inserted_at,
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
              %{passkey: Passkey.generate()}
            )

          {:passphrase, Repo.insert!(passphrase_changeset)}
        else
          one_time_code_invalidation_changeset =
            OneTimeCodeInvalidation.changeset(
              %OneTimeCodeInvalidation{},
              %{one_time_code_id: otc.id}
            )

          Repo.insert!(one_time_code_invalidation_changeset)

          {:error, :mismatch}
        end
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
    insecure_authentication_handle_changeset =
      InsecureAuthenticationHandle.changeset(%InsecureAuthenticationHandle{},
                                             %{passkey: Passkey.generate(),
                                               user_id: user.id})

    {:insecure_authentication_handle, Repo.insert!(insecure_authentication_handle_changeset)}
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

  defp respond_with_success(conn,
                            :insecure_authentication_handle,
                            insecure_authentication_handle) do
    conn
    |> put_status(:created)
    |> render(Spherium.AuthenticationResultView,
              "show.insecure_authentication_handle.json",
              insecure_authentication_handle: insecure_authentication_handle)
  end

  defp respond_with_success(conn, :passphrase, passphrase) do
    conn
    |> put_status(:created)
    |> render(Spherium.AuthenticationResultView,
              "show.passphrase.json",
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

  defp respond_with_failure(conn, :not_found) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(:not_found, "Pair not found.")
  end
end
