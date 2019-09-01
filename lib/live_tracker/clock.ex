defmodule LiveTracker.Clock do
  @moduledoc """
  This server is responsible for syncing the position of a song between
  multiple connected clients.
  """
  defstruct bpm: 120, playing: false, song_position: 0, timer: nil, song_id: nil

  use GenServer

  def start_link(song_id, opts \\ []) when is_binary(song_id) and is_list(opts) do
    state = struct(__MODULE__, [{:song_id, song_id} | opts])
    GenServer.start_link(__MODULE__, state, name: registered_name(song_id))
  end

  def play(song_id) do
    song_id
    |> registered_name()
    |> GenServer.cast(:play)
  end

  def stop(song_id) do
    song_id
    |> registered_name()
    |> GenServer.cast(:stop)
  end

  def update_tempo(song_id, bpm) do
    song_id
    |> registered_name()
    |> GenServer.cast({:update_tempo, bpm})
  end

  @doc """
  Process name for which can be shared among clients connected to a song.
  """
  def registered_name(song_id) do
    {:via, Registry, {LiveTracker.ClockRegistry, song_id}}
  end

  @spec lookup_pid(any) :: nil | pid | {atom, atom}
  def lookup_pid(song_id) do
    song_id |> registered_name() |> GenServer.whereis()
  end

  # callbacks

  @impl true
  def init(%__MODULE__{} = state) do
    {:ok, state |> maybe_loop()}
  end

  @impl true
  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast(:play, state) do
    # Prevent doubling of the BPM if the play button is pressed twice.
    unless state.playing do
      {:noreply,
       state
       |> Map.put(:playing, true)
       |> maybe_loop()
       |> notify_subscribers()}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast(:stop, state) do
    {:noreply,
     state
     |> maybe_reset_song_position()
     |> Map.put(:playing, false)
     |> maybe_loop()
     |> notify_subscribers()}
  end

  @impl true
  def handle_cast({:update_tempo, bpm}, state) do
    {:noreply, %{state | bpm: bpm}}
  end

  @impl true
  def handle_info(:maybe_loop, state) do
    {:noreply,
     %{state | song_position: state.song_position + 1}
     |> maybe_loop()
     |> notify_subscribers()}
  end

  defp maybe_loop(%{playing: false, timer: nil} = state), do: state
  defp maybe_loop(%{playing: false} = state), do: state |> cancel_timer()
  defp maybe_loop(%{playing: true, bpm: bpm} = state) when is_integer(bpm), do: state |> loop()

  # Reset song position if stopped twice.
  defp maybe_reset_song_position(%{playing: false} = state), do: %{state | song_position: 0}
  defp maybe_reset_song_position(%{playing: true} = state), do: state

  defp cancel_timer(state) do
    # Cancel timer if it is still running.
    Process.cancel_timer(state.timer)

    %{state | timer: nil}
  end

  defp loop(state) do
    time_in_ms = round(60 / state.bpm * 1_000)
    timer = Process.send_after(self(), :maybe_loop, time_in_ms)

    %{state | timer: timer}
  end

  defp notify_subscribers(state) do
    :ok =
      LiveTracker.PubSub
      |> Phoenix.PubSub.broadcast("clock:#{state.song_id}", {:clock, state})

    state
  end
end
