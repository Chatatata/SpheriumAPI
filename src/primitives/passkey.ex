defmodule Spherium.Passkey do
  @moduledoc """
  Property representing the secure data of an access token.

  A passkey is simply a concatenation of four UUIDs (Version 4).
  """

  @doc """
  Generates a string passkey with an absolute length of 88.
  """
  @spec generate() :: String.t
  def generate() do
    Base.encode64(bingenerate(), padding: true)
  end

  @doc """
  Generates a binary passkey.
  """
  @spec bingenerate() :: binary
  def bingenerate() do
    Enum.map_join(1..4, fn(_) -> Ecto.UUID.bingenerate() end)
  end
end
