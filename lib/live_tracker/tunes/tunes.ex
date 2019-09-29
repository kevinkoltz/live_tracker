defmodule LiveTracker.Tunes do
  @moduledoc """
  Context module for loading and updating tunes (`LiveTracker.Tunes.Tune`).
  """

  alias LiveTracker.Tunes.{Note, Tune}

  @doc """
  List saved tunes.

  Currently this is a fixed list for demo.
  """
  @spec list_tunes :: [Tune.t()]
  def list_tunes do
    [
      %Tune{
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
      %Tune{
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
  Loads a saved tune by id.
  """
  @spec load_tune(Tune.id()) :: {:ok, Tune.t()} | {:error, :not_found}
  def load_tune(id) do
    list_tunes() |> do_load_tune(id)
  end

  defp do_load_tune([%Tune{id: id} = tune | _], id), do: {:ok, tune}
  defp do_load_tune([_ | t], id), do: do_load_tune(t, id)
  defp do_load_tune([], _), do: {:error, :not_found}

  @doc """
  Records a note into a tune at given step.
  """
  @spec record_note(Tune.t(), Note.t(), Tune.track_id(), Tune.line_id()) ::
          Tune.t()

  def record_note(tune, note, track_id, line_id) do
    notes = Map.put(tune.notes, {track_id, line_id}, note)
    %Tune{tune | notes: notes}
  end

  @doc """
  Clears a note into a tune at given step.
  """
  @spec clear_note(Tune.t(), Tune.track_id(), Tune.line_id()) ::
          Tune.t()
  def clear_note(tune, track_id, line_id) do
    notes = Map.delete(tune.notes, {track_id, line_id})
    %Tune{tune | notes: notes}
  end

  @doc """
  Allow song playback syncing between multiple browser sessions.
  """
  def subscribe("clock:" <> song_id) when is_binary(song_id) do
    Phoenix.PubSub.subscribe(LiveTracker.PubSub, "clock:" <> song_id)
  end
end
