defmodule LiveTrackerWeb.SequencerView do
  use LiveTrackerWeb, :view

  alias LiveTracker.Note

  @max_song_name_length 20

  def song_name_format(song_name) when is_binary(song_name) do
    String.pad_trailing(song_name, @max_song_name_length - byte_size(song_name), "_")
  end

  @spec note_format(Note.t() | {String.t(), Note.octave()}) :: String.t()
  def note_format(nil), do: "---"

  def note_format({note, octave}) when is_atom(note),
    do: {to_string(note), octave} |> note_format()

  def note_format({<<note::binary-size(1), "b">>, octave}), do: "#{note}##{octave}"
  def note_format({note, octave}), do: "#{note}-#{octave}"

  @spec number_format(binary | integer, keyword) :: binary
  def number_format(value, opts \\ [])

  def number_format(value, opts) when is_integer(value) do
    value
    |> to_string
    |> number_format(opts)
  end

  def number_format(value, opts) do
    hex? = Keyword.get(opts, :hex, false)
    padding = Keyword.get(opts, :padding, nil)

    maybe_hex = fn
      value, true -> Hexadecimal.from_base10(value)
      value, false -> value
    end

    maybe_pad = fn
      value, nil -> value
      value, padding -> String.pad_leading(value, padding, "0")
    end

    value
    |> maybe_hex.(hex?)
    |> maybe_pad.(padding)
  end
end
