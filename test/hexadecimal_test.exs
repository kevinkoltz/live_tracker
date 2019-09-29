defmodule HexadecimalTest do
  @moduledoc false
  use ExUnit.Case, async: true
  doctest Hexadecimal

  describe "from_base10" do
    test "converts to hexadecimal" do
      assert Hexadecimal.from_base10(0) == "0"
      assert Hexadecimal.from_base10(1) == "1"
      assert Hexadecimal.from_base10(10) == "A"
      assert Hexadecimal.from_base10(16) == "10"
      assert Hexadecimal.from_base10(17) == "11"
      assert Hexadecimal.from_base10(255) == "FF"
      assert Hexadecimal.from_base10(256) == "100"
      assert Hexadecimal.from_base10(7562) == "1D8A"
      assert Hexadecimal.from_base10(35_631) == "8B2F"
    end
  end
end
