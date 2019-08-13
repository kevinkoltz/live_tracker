defmodule LiveTracker do
  @moduledoc """
  LiveTracker keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias LiveTracker.Sequence

  @doc """
  List saved sequences.

  Currently this is a fixed list for demo.
  """
  @spec list_sequences :: [Sequence.t()]
  def list_sequences do
    [
      %Sequence{
        id: "01",
        filename: "MOUNTNKING.MOD",
        name: "MOUNTNKING",
        notes: %{
          {0, 0} => {:A, 4},
          {0, 1} => {:B, 4},
          {0, 2} => {:C, 4},
          {0, 3} => {:D, 4},
          {0, 4} => {:E, 4},
          {0, 5} => {:C, 4},
          {0, 6} => {:E, 4},
          {2, 8} => {:Db, 4},
          {2, 9} => {:B, 4},
          {2, 10} => {:Db, 4},
          {3, 12} => {:D, 4},
          {3, 13} => {:B, 4},
          {3, 14} => {:D, 4}
        }
      },
      %Sequence{
        id: "02",
        filename: "MARIO.MOD",
        name: "MARIOBROS",
        notes: %{
          {0, 0} => {:C, 5},
          {0, 1} => {:G, 4},
          {0, 2} => {:E, 4},
          {0, 3} => nil,
          {0, 4} => nil,
          {1, 5} => {:A, 4},
          {1, 6} => {:B, 4},
          {1, 7} => nil,
          {1, 8} => {:Bb, 4},
          {1, 9} => {:A, 4},
          {0, 10} => nil,
          {3, 11} => {:G, 4},
          {3, 12} => {:E, 5},
          {3, 13} => {:G, 5},
          {3, 14} => {:A, 5},
          {0, 15} => nil
        }
      }
      # G ^E ^G ^A
      # TODO: add option for patterns so we can have more notes.
      # ^F ^G ^E ^C ^D B
    ]
  end

  @doc """
  Loads a saved sequence by id.
  """
  @spec load_sequence(Sequence.id()) :: {:ok, Sequence.t()} | {:error, :not_found}
  def load_sequence(id) do
    list_sequences() |> do_load_sequence(id)
  end

  defp do_load_sequence([%Sequence{id: id} = sequence | _], id), do: {:ok, sequence}
  defp do_load_sequence([_ | t], id), do: do_load_sequence(t, id)
  defp do_load_sequence([], _), do: {:error, :not_found}

  @doc """
  Records a note into a sequence at given position.
  """
  @spec record_note(Sequence.t(), Note.t() | :clear, Note.track_id(), Note.line_id()) ::
          Sequence.t()
  def record_note(sequence, :clear, track_id, line_id) do
    notes = Map.delete(sequence.notes, {track_id, line_id})
    %Sequence{sequence | notes: notes}
  end

  def record_note(sequence, note, track_id, line_id) do
    notes = Map.put(sequence.notes, {track_id, line_id}, note)
    %Sequence{sequence | notes: notes}
  end
end
