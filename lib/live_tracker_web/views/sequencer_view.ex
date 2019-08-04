defmodule LiveTrackerWeb.SequencerView do
  use LiveTrackerWeb, :view

  @spec padded_format(binary | integer, non_neg_integer) :: binary
  def padded_format(value, pad_count) when is_integer(value) do
    value
    |> to_string
    |> padded_format(pad_count)
  end

  def padded_format(value, pad_count) when is_binary(value) do
    value
    |> Hexadecimal.from_base10()
    |> String.pad_leading(pad_count, "0")
  end
end
