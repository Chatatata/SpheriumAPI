defmodule Spherium.OneTimeCodeSubmission do
  use Spherium.Web, :model

  schema "one_time_code_submissions" do
    field :code, :integer
    belongs_to :user, Spherium.User
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:code, :user_id])
    |> validate_required([:code, :user_id])
    |> validate_inclusion(:code, 100000..999999)
    |> foreign_key_constraint(:user_id)
  end
end
