defmodule LiveTrackerWeb.SequencerLive do
  use Phoenix.LiveView

  alias LiveTrackerWeb.SequencerView

  @initial bpm: 120,
           playing: false,
           recording: false,
           position: 1,
           tracks: 4,
           selected_track: 1,
           length: 16,
           octave: 4,
           current_note: nil,
           sequence: %{
             1 => %{notes: ["A4"]},
             2 => %{notes: ["B4"]},
             3 => %{notes: ["C4"]},
             4 => %{notes: ["D4"]},
             5 => %{notes: ["E4"]},
             6 => %{notes: ["C4"]},
             7 => %{notes: ["E4"]},
             8 => %{notes: []},
             9 => %{notes: ["Db4"]},
             10 => %{notes: ["B4"]},
             11 => %{notes: ["Db4"]},
             12 => %{notes: []},
             13 => %{notes: ["D4"]},
             14 => %{notes: ["B4"]},
             15 => %{notes: ["D4"]},
             16 => %{notes: []}
           }

  def render(assigns) do
    SequencerView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    updated_socket = assign(socket, @initial)

    if connected?(socket) do
      schedule_tick(updated_socket)
    end

    {:ok, updated_socket}
  end

  # Transport

  def handle_event("play", _, socket), do: {:noreply, play(socket)}
  def handle_event("stop", _, socket), do: {:noreply, stop(socket)}
  def handle_event("record", _, socket), do: {:noreply, record(socket)}

  def handle_event("keydown", "ArrowRight", socket), do: {:noreply, select_track(socket, :next)}
  def handle_event("keydown", "ArrowLeft", socket), do: {:noreply, select_track(socket, :prev)}

  # Keyboard notes

  def handle_event("keydown", "a", socket), do: {:noreply, play_note(socket, :C)}
  def handle_event("keydown", "w", socket), do: {:noreply, play_note(socket, :Cb)}
  def handle_event("keydown", "s", socket), do: {:noreply, play_note(socket, :D)}
  def handle_event("keydown", "e", socket), do: {:noreply, play_note(socket, :Db)}
  def handle_event("keydown", "d", socket), do: {:noreply, play_note(socket, :E)}
  def handle_event("keydown", "f", socket), do: {:noreply, play_note(socket, :F)}
  def handle_event("keydown", "t", socket), do: {:noreply, play_note(socket, :Fb)}
  def handle_event("keydown", "g", socket), do: {:noreply, play_note(socket, :G)}
  def handle_event("keydown", "y", socket), do: {:noreply, play_note(socket, :Gb)}
  def handle_event("keydown", "h", socket), do: {:noreply, play_note(socket, :A)}
  def handle_event("keydown", "u", socket), do: {:noreply, play_note(socket, :Ab)}
  def handle_event("keydown", "j", socket), do: {:noreply, play_note(socket, :B)}

  def handle_event("keydown", "k", socket),
    do: {:noreply, play_note(socket, :C, octave_shift_amount: 1)}

  ## Octave up/down

  def handle_event("keydown", "z", socket), do: {:noreply, change_octave(socket, :down)}
  def handle_event("keydown", "x", socket), do: {:noreply, change_octave(socket, :up)}

  def handle_event("keydown", _, socket), do: {:noreply, socket}

  # def handle_event(event, message, socket) do
  #   IO.inspect({event, message}, label: "event not handled")
  #   {:noreply, socket}
  # end

  def handle_info(:tick, socket) do
    {:noreply, socket |> schedule_tick() |> advance()}
  end

  ## Transport

  defp play(socket), do: assign(socket, playing: true)

  defp stop(%{assigns: %{playing: false, position: position}} = socket) when position > 1 do
    socket
    |> reset_position()
    |> stop()
  end

  defp stop(socket), do: assign(socket, playing: false, recording: false)

  defp record(%{assigns: %{playing: false}} = socket), do: socket |> toggle_recording() |> play()
  defp record(%{assigns: %{playing: true}} = socket), do: socket |> toggle_recording()

  def toggle_recording(socket), do: assign(socket, recording: !socket.assigns.recording)

  defp advance(%{assigns: %{playing: false}} = socket), do: socket
  defp advance(%{assigns: %{position: n, length: n}} = socket), do: reset_position(socket)
  defp advance(socket), do: update(socket, :position, &(&1 + 1))

  defp reset_position(socket), do: socket |> assign(position: 1)

  ## Notes

  defp change_octave(socket, :up),
    do: assign(socket, :octave, shift_octave(socket.assigns.octave, 1))

  defp change_octave(socket, :down),
    do: assign(socket, :octave, shift_octave(socket.assigns.octave, -1))

  defp shift_octave(octave, amount) when octave + amount < 0, do: 0
  defp shift_octave(octave, amount) when octave + amount > 8, do: 8
  defp shift_octave(octave, amount), do: octave + amount

  defp play_note(socket, note, opts \\ []) when is_atom(note) do
    octave_shift_amount = Keyword.get(opts, :octave_shift_amount, 0)

    octave = shift_octave(socket.assigns.octave, octave_shift_amount)

    socket
    |> assign(:current_note, to_string(note) <> to_string(octave))
    |> maybe_record()
  end

  defp maybe_record(%{assigns: %{recording: false}} = socket), do: socket

  defp maybe_record(%{assigns: %{recording: true}} = socket) do
    # TODO: update sequence for current selected track
    socket
  end

  ## Tracks

  defp select_track(socket, :prev),
    do: assign(socket, :octave, max(1, socket.assigns.selected_track - 1))

  defp select_track(socket, :next),
    do: assign(socket, :octave, min(socket.assigns.tracks, socket.assigns.selected_track + 1))

  ## Loop

  defp schedule_tick(socket) do
    time_in_ms = round(60 / socket.assigns.bpm * 1_000)
    Process.send_after(self(), :tick, time_in_ms)
    socket
  end
end
