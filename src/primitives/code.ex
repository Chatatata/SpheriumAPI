defmodule Spherium.Code do
  @moduledoc """
  Property representing 6-digit numeric code.

  A typical use case of the primitive would be in one-time-code authentication middleware.

  This module uses Erlang's `:crypto` module secure pseudo-random number generator.
  """

  @lower_bound 100000
  @upper_bound 1000000

  @doc """
  Generates an integer code between 100000 and 999999, inclusive.
  """
  @spec generate() :: integer
  def generate() do
    :crypto.rand_uniform(@lower_bound, @upper_bound)
  end
end
