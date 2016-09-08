defmodule SpheriumWebService.CredentialValidationService do
  use SpheriumWebService.Web, :service

  alias SpheriumWebService.User
  alias SpheriumWebService.CredentialValidationService.UserNotFound

  import Comeonin.Bcrypt, only: [checkpw: 2]

  def check_credentials(username, password) do
    query = from u in User,
            where: u.username == ^username

    case Repo.one(query) do
      nil ->
        {:error, nil}
      user ->
        if checkpw(password, user.password_digest) do
          {:accepted, user}
        else
          {:invalid, user.id}
        end
    end
  end

  def check_credentials!(username, password) do
    case check_credentials(username, password) do
      {:ok, result} ->
        result
      {:error, nil} ->
        raise UserNotFound, username
    end
  end
end

defmodule SpheriumWebService.CredentialValidationService.UserNotFound do
  defexception [:message]

  def exception(username) do

    msg = """
    user with given username not found:

    #{username}
    """

    %__MODULE__{message: msg}
  end
end
