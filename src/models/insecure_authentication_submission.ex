defmodule Spherium.InsecureAuthenticationSubmission do
  use Spherium.Web, :virtual

  embedded_schema do
    field :passkey, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:passkey])
    |> validate_required([:passkey])
    |> validate_length(:passkey, is: 88)
  end
end
