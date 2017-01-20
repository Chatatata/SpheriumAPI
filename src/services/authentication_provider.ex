defmodule Spherium.AuthenticationProvider do
  @moduledoc """
  This module is responsible for authentication completion challenge scenario handlers and their
  finalizers.
  """

  import Ecto.Query, only: [from: 2]

  alias Spherium.Repo
  alias Spherium.Passkey
  alias Spherium.InsecureAuthenticationHandle
  alias Spherium.OneTimeCode
  alias Spherium.Passphrase
  alias Spherium.OneTimeCodeInvalidation
  alias Spherium.Code
  alias Spherium.User

  @doc """
  Challenges user with insecure authentication handle.
  """
  @spec challenge_with_handle(String.t, DeviceInformation.t) ::
        no_return |
        {:passphrase, Passphrase.t}
  def challenge_with_handle(passkey, device_information) do
    query = from iah in InsecureAuthenticationHandle,
            join: u in User, on: iah.user_id == u.id,
            left_join: p in Passphrase, on: p.inserted_at > iah.inserted_at,
            where: iah.passkey == ^passkey and
                   iah.inserted_at > ago(3, "minute") and
                   is_nil(p.id),
            select: iah

    case Repo.one(query) do
      nil ->
        Repo.rollback(:not_found)
      iah ->
        passphrase_changeset =
          Passphrase.changeset(
            %Passphrase{},
            %{passkey: Passkey.generate(),
              user_id: iah.user_id,
              device: device_information.device,
              user_agent: device_information.user_agent}
          )

        {:passphrase, Repo.insert!(passphrase_changeset)}
    end
  end

  @doc """
  Challenges user with one time code.
  """
  @spec challenge_user_with_otc(integer, integer, DeviceInformation.t) ::
        no_return |
        {:passphrase, Passphrase.t} |
        {:error, :mismatch}
  def challenge_user_with_otc(user_id, code, device_information) do
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
              %{passkey: Passkey.generate(),
                user_id: otc.user_id,
                device: device_information.device,
                user_agent: device_information.user_agent}
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

  @doc """
  Performs concrete authentication instantiation on user with corresponding authentication
  scheme.
  """
  def apply_authentication_scheme(user) do
    apply_authentication_scheme(user, user.authentication_scheme)
  end

  defp apply_authentication_scheme(user, :insecure) do
    insecure_authentication_handle_changeset =
      InsecureAuthenticationHandle.changeset(%InsecureAuthenticationHandle{},
                                             %{passkey: Passkey.generate(),
                                               user_id: user.id})

    {:insecure_authentication_handle, Repo.insert!(insecure_authentication_handle_changeset)}
  end

  defp apply_authentication_scheme(user, :two_factor_over_otc) do
    query = from otc in OneTimeCode,
            left_join: otci in OneTimeCodeInvalidation, on: otci.one_time_code_id == otc.id,
            left_join: p in Passphrase, on: p.inserted_at > otc.inserted_at,
            where: otc.user_id == ^user.id and
                   otc.inserted_at > ago(15, "minute") and
                   is_nil(otci.id) and
                   is_nil(p.id),
            select: otc

    if Repo.aggregate(query, :count, :id) == 2, do: Repo.rollback(:otc_quota_reached)

    one_time_code_changeset =
      OneTimeCode.changeset(
        %OneTimeCode{},
        %{user_id: user.id,
          code: Code.generate()}
      )

    {:one_time_code, Repo.insert!(one_time_code_changeset)}
  end

  defp apply_authentication_scheme(_user, :two_factor_over_tbc) do
    Repo.rollback(:tbc_not_available)
  end
end
