defmodule Spherium.Subscriber do
  use Spherium.Web, :model

  schema "subscribers" do
    field :address, :string

    timestamps()
  end
  
  @allowed_fields ~w(address)a
  @required_fields ~w(address)a
  
  @email_regex ~r/(\w+)@([\w.]+)/

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @allowed_fields)
    |> validate_required(@required_fields)
    |> validate_format(:address, @email_regex)          # Validate email
  end
end
