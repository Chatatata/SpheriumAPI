defmodule Spherium.PasskeyTest do
  use Spherium.ModelCase

  alias Spherium.Passkey

  test "generates a binary passkey" do
    assert Passkey.bingenerate()
  end

  test "generates a Base64 passkey with absolute length of 88" do
    passkey = Passkey.generate()

    assert passkey
    assert String.length(passkey) == 88
  end
end
