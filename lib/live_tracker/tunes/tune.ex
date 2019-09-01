defmodule LiveTracker.Tunes.Tune do
  @moduledoc """
  Date structure for a song and it's sequence of notes.
  """

  defstruct id: nil, name: nil, filename: nil, notes: %{}

  alias LiveTracker.Tunes.Note

  @type id :: Hexadecimal.t()
  @type name :: String.t()
  @type filename :: String.t()

  @type track_id :: non_neg_integer()
  @type line_id :: non_neg_integer()

  @type t :: %__MODULE__{
          id: id,
          name: name,
          filename: filename,
          notes: %{
            {track_id, line_id} => Note.t()
          }
        }

  @doc """
  Returns a new tune.
  """
  @spec new(filename, name) :: t
  # TODO: UNTITLED02.. UNTITLED03..
  def new(id, filename \\ "UNTITLED.MOD", name \\ "Untitled") do
    %__MODULE__{id: id, name: name, filename: filename}
  end

  @doc """
  Returns a note at a specific step (line) for a given tracks pattern.
  """
  @spec note_at_step(t, track_id, line_id) :: Note.t()
  def note_at_step(tune, track_id, line_id) do
    Map.get(tune, {track_id, line_id})
  end
end
