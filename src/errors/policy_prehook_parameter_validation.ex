defmodule Spherium.PolicyPrehookParameterValidationError do
  defexception [:changeset, plug_status: 422]

  def message(%{changeset: changeset}) do
    Ecto.InvalidChangesetError.message(%{action: :"policy prehook", changeset: changeset})
  end
end
