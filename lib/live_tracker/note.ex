defmodule LiveTracker.Note do
  @moduledoc """
  Date structure for representing an instance of a note to be played.

  This may be updated to optionally include velocity and length.
  """

  @type note :: :C | :Cb | :D | :Db | :E | :F | :Fb | :G | :Gb | :A | :Ab | :B
  @type octave :: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8
  @type t :: {note, octave}
  # @type t :: {note, octave} | {note, octave, length} | {note, octave, length, velocity}
end
