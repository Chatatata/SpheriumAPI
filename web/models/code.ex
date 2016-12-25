defmodule Spherium.Code do
  @lower_bound 100000
  @upper_bound 1000000

  def generate() do
    :crpyto.rand_uniform(@lower_bound, @upper_bound)
  end
end
