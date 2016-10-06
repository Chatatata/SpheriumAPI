defmodule Spherium.Passkey do
  def generate() do
    Base.encode64(bingenerate(), padding: false)
  end

  def bingenerate() do
    Enum.map_join(1..4, fn(_) -> Ecto.UUID.bingenerate() end)
  end
end
