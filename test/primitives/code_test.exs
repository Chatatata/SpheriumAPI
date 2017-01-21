defmodule Spherium.CodeTest do
  use Spherium.ModelCase

  alias Spherium.Code

  test "generates a valid integer code between 100000 and 1000000 (stochastic)" do
    code = Code.generate()

    assert code
    assert code >= 100000
    assert code <= 999999
  end
end
