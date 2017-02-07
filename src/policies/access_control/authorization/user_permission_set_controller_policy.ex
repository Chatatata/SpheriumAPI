defmodule Spherium.UserPermissionSetControllerPolicy do
  alias Spherium.PolicyPrehookParameterValidationError

  def show(conn, %{"user_id" => user_id}, :self) when is_binary(user_id) do
    try do
      show(conn, %{"user_id" => String.to_integer(user_id)}, :self)
    rescue
      _ ->
        data = %{}
        types = %{user_id: :integer}

        changeset =
          {data, types}
          |> Ecto.Changeset.cast(%{"user_id" => user_id}, Map.keys(types))

        raise PolicyPrehookParameterValidationError, changeset: changeset
    end
  end

  def show(conn, %{"user_id" => user_id}, :self) do
    conn.assigns[:user].id == user_id
  end
end
