defmodule Spherium.Authorization.Helpers do
  @moduledoc """
  Convenience functions of testing/validating authorization primitives.
  """

  @doc """
  Tests a predicate, raises if value is fallacy.
  """
  @spec validate_predicate(boolean) ::
    no_return
  defmacro validate_predicate(predicate) do
    quote do
      unless unquote(predicate),
        do: raise Spherium.InsufficientScopeError
    end
  end

  @doc """
  Validates possession of a given entity by the authorizer
  of the connection.
  """
  @spec validate_possession(Plug.Conn, Ecto.Queryable) ::
    no_return
  defmacro validate_possession(conn, entity) do
    quote do
      validate_predicate unquote(conn).assigns[:user].id ==
                         unquote(entity).user_id
    end
  end
end
