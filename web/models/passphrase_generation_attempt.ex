defmodule Spherium.PassphraseGenerationAttempt do
  use Spherium.Web, :model

  schema "passphrase_generation_attempts" do
    field :code, :integer
    field :user_id, :integer
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:code, :user_id])
    |> validate_required([:code, :user_id])
    |> validate_inclusion(:code, 100000..1000000)
  end
end
