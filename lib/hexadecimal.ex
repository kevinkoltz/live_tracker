defmodule Hexadecimal do
  @moduledoc """
  Functions for handling base-16 hexadecimal numbers.
  """

  @type t :: binary()

  @doc """
  Converts base-10 into hexadecimal.

  Examples:

      iex> Hexadecimal.from_base10(10)
      "A"

      iex> Hexadecimal.from_base10(16)
      "10"

      iex> Hexadecimal.from_base10(255)
      "FF"

  """
  @spec from_base10(binary | integer | Decimal.t()) :: t()

  def from_base10(number) do
    number
    |> Decimal.new()
    |> do_from_base10([])
  end

  defp do_from_base10(%Decimal{coef: 0}, []) do
    "0"
  end

  defp do_from_base10(%Decimal{coef: 0}, remainders) do
    remainders
    |> Enum.map(fn
      10 -> "A"
      11 -> "B"
      12 -> "C"
      13 -> "D"
      14 -> "E"
      15 -> "F"
      n when is_integer(n) -> to_string(n)
    end)
    |> Enum.join()
  end

  defp do_from_base10(%Decimal{} = number, remainders) do
    {quotient, %Decimal{coef: remainder, exp: 0}} = Decimal.div_rem(number, 16)
    do_from_base10(quotient, [remainder | remainders])
  end
end
