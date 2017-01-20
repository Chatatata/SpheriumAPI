defmodule Spherium.AuthenticationController do
  use Spherium.Web, :controller

  import Ecto.Changeset, only: [get_field: 2, apply_changes: 1]
  import Comeonin.Bcrypt, only: [checkpw: 2]
  import Spherium.AuthenticationProvider

  alias Spherium.Credentials
  alias Spherium.Attempt
  alias Spherium.Passphrase
  alias Spherium.PassphraseInvalidation
  alias Spherium.OneTimeCodeSubmission
  alias Spherium.User
  alias Spherium.InsecureAuthenticationSubmission
  alias Spherium.DeviceInformation

  def create(conn,
             %{"credentials" => credentials}) do
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
               "device_information" => device_information_params}) do
    validate_device_params conn, device_information_params, fn (device_information) ->
      submission_changeset =
        InsecureAuthenticationSubmission.changeset(%InsecureAuthenticationSubmission{},
                                                   insecure_authentication_submission)

      if submission_changeset.valid? do
        passkey = get_field(submission_changeset, :passkey)

        result = Repo.transaction(fn ->
          challenge_with_handle passkey, device_information
        end)

        respond(conn, result)
      else
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spherium.ChangesetView, "error.json", changeset: submission_changeset)
      end
    end
  end

  def create(conn, %{"one_time_code_submission" => one_time_code_submission,
                     "device_information" => device_information_params}) do
    validate_device_params conn, device_information_params, fn (device_information) ->
      one_time_code_submission_changeset =
        OneTimeCodeSubmission.changeset(
          %OneTimeCodeSubmission{},
          one_time_code_submission
        )

      if one_time_code_submission_changeset.valid? do
        user_id = get_field(one_time_code_submission_changeset, :user_id)
        code = get_field(one_time_code_submission_changeset, :code)

        result = Repo.transaction(fn ->
          challenge_user_with_otc user_id, code, device_information
        end)

        respond(conn, result)
      else
        conn
        |> put_status(:unprocessable_entity)
        |> render(Spherium.ChangesetView,
                  "error.json",
                  changeset: one_time_code_submission_changeset)
      end
    end
  end

  defp validate_device_params(conn, params, function) do
    device_information_changeset =
      DeviceInformation.changeset(%DeviceInformation{},
                                  params)

    if device_information_changeset.valid? do
      function.(apply_changes(device_information_changeset))
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Spherium.ChangesetView,
                "error.json",
                changeset: device_information_changeset)
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
    |> render(Spherium.PassphraseView,
              "show.private.json",
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
