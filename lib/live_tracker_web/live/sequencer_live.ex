defmodule LiveTrackerWeb.SequencerLive do
  use Phoenix.LiveView

  alias LiveTracker.Sequence
  alias LiveTrackerWeb.SequencerView
  alias LiveTrackerWeb.Router.Helpers, as: Routes

  @initial bpm: 200,
           playing: false,
           recording: false,
           position: 0,
           pattern: 254,
           tracks: 4,
           selected_track: 1,
           length: 16,
           octave: 4,
           current_note: nil,
           controls_view: "controls",
           # TODO: look this up after mount is connected.
           sequences: LiveTracker.list_sequences(),
           # Key: {track, line/position}
           # TODO: generate hexadecimal id (max from existing sequences + 1)
           sequence: Sequence.new("FF"),
           load_file_selected_id: nil

  def render(assigns), do: SequencerView.render("index.html", assigns)

  def mount(_session, socket) do
    updated_socket = assign(socket, @initial)

    if connected?(socket) do
      schedule_tick(updated_socket)
    end

    {:ok, updated_socket}
  end

  ## Transport

  def handle_event("play", _, socket), do: {:noreply, play(socket)}
  def handle_event("keydown", " ", socket), do: {:noreply, toggle_playing(socket)}
  def handle_event("stop", _, socket), do: {:noreply, stop(socket)}
  def handle_event("record", _, socket), do: {:noreply, record(socket)}

  ## Tracks

  def handle_event("select_track", track_id, socket),
    do: {:noreply, select_track(socket, String.to_integer(track_id))}

  def handle_event("keydown", "ArrowRight", socket), do: {:noreply, select_track(socket, :next)}
  def handle_event("keydown", "ArrowLeft", socket), do: {:noreply, select_track(socket, :prev)}

  ## Keyboard notes

  # TODO: this should temporarily overwrite sequence so both notes do not clobber each other

  def handle_event("keydown", key, socket)
      when key in ["a", "w", "s", "e", "d", "f", "t", "g", "y", "h", "u", "j", "m"] do
    %{octave: octave, position: position, selected_track: selected_track} = socket.assigns

    note = key_to_note(key, octave)

    send(self(), {:maybe_record, note, selected_track, position})

    {:noreply, play_note(socket, note)}
  end

  ## Octave up/down

  def handle_event("keydown", "z", socket), do: {:noreply, change_octave(socket, :down)}
  def handle_event("keydown", "x", socket), do: {:noreply, change_octave(socket, :up)}

  def handle_event("keydown", keydown, socket) do
    IO.inspect(keydown, label: "keydown")
    {:noreply, socket}
  end

  ## Control Views

  def handle_event("toggle_controls_view", view, socket)
      when view in [
             "load",
             "save",
             "upload",
             "scale",
             "theme",
             "instrument_edit",
             "pattern_edit",
             "sample_edit",
             "controls"
           ] do
    case view do
      "save" ->
        {:stop,
         socket
         |> put_flash(
           :error,
           "Not ready reading drive A:  Abort, Retry, Fail?"
         )
         |> redirect(to: Routes.live_path(socket, LiveTrackerWeb.SequencerLive))}

      "upload" ->
        {:stop,
         socket
         |> put_flash(
           :error,
           "Error: TRACKER LOAD MOD"
         )
         |> redirect(to: Routes.live_path(socket, LiveTrackerWeb.SequencerLive))}

      view when view in ["load"] ->
        {:noreply, toggle_controls_view(socket, view)}

      view ->
        {:stop,
         socket
         |> put_flash(
           :error,
           "Error: #{view} not implemented."
         )
         |> redirect(to: Routes.live_path(socket, LiveTrackerWeb.SequencerLive))}
    end
  end

  ## File Operations

  # TODO: move these into child liveviews?

  def handle_event("new", _, socket) do
    {:noreply, assign(socket, sequence: Sequence.new("FF"))}
  end

  def handle_event("load", _, socket) do
    id = socket.assigns.load_file_selected_id

    # TODO: load from saved sequences
    case LiveTracker.load_sequence(id) do
      {:ok, sequence} ->
        {:noreply,
         socket
         |> assign(sequence: sequence)
         |> toggle_controls_view("load")}

      {:error, :not_found} ->
        {:stop,
         socket
         |> put_flash(
           :error,
           "File not found: #{id}"
         )
         |> redirect(to: Routes.live_path(socket, LiveTrackerWeb.SequencerLive))}
    end
  end

  def handle_event("select_load_file", id, socket) do
    {:noreply, socket |> assign(load_file_selected_id: id)}
  end

  def handle_event("upload", _, _socket), do: {:error, "Not implemented"}
  def handle_event("save", _, _socket), do: {:error, "Not implemented"}

  # def handle_event(event, message, socket) do
  #   IO.inspect({event, message}, label: "event not handled")
  #   {:noreply, socket}
  # end

  def handle_info(:tick, socket) do
    # Sending async message to play notes to help prevent any delays in timing.
    # TODO: Look into using GenStage for handling the sequencing and
    # broadcasting of notes to the Tone.js socket from GenStage consumers.
    send(self(), {:maybe_play, socket.assigns.position})
    {:noreply, socket |> schedule_tick() |> advance()}
  end

  def handle_info({:maybe_play, position}, %{assigns: %{playing: true}} = socket) do
    %{assigns: %{sequence: sequence}} = socket

    for track <- 0..(socket.assigns.tracks - 1) do
      note = Map.get(sequence.notes, {track, position})

      if note do
        play_note(socket, note, track: track)
      end
    end

    {:noreply, socket}
  end

  def handle_info({:maybe_play, _}, %{assigns: %{playing: false}} = socket) do
    {:noreply, socket}
  end

  def handle_info({:maybe_record, _, _, _}, %{assigns: %{recording: false}} = socket) do
    {:noreply, socket}
  end

  def handle_info({:maybe_record, note, track, position}, %{assigns: %{recording: true}} = socket) do
    sequence =
      socket.assigns.sequence
      |> LiveTracker.record_note(note, track, position)

    {:noreply, socket |> assign(sequence: sequence)}
  end

  ## Transport

  defp play(socket), do: assign(socket, playing: true)
  defp toggle_playing(socket), do: assign(socket, playing: !socket.assigns.playing)

  defp stop(%{assigns: %{playing: false, position: position}} = socket) when position > 0 do
    socket
    |> reset_position()
    |> stop()
  end

  defp stop(socket), do: assign(socket, playing: false, recording: false)

  defp record(%{assigns: %{playing: false}} = socket), do: socket |> toggle_recording() |> play()
  defp record(%{assigns: %{playing: true}} = socket), do: socket |> toggle_recording()

  def toggle_recording(socket), do: assign(socket, recording: !socket.assigns.recording)

  defp advance(%{assigns: %{playing: false}} = socket), do: socket

  defp advance(%{assigns: %{position: position, length: length}} = socket)
       when position + 1 == length,
       do: reset_position(socket)

  defp advance(socket), do: update(socket, :position, &(&1 + 1))

  defp reset_position(socket), do: socket |> assign(position: @initial[:position])

  ## Notes

  defp change_octave(socket, :up),
    do: assign(socket, :octave, shift_octave(socket.assigns.octave, 1))

  defp change_octave(socket, :down),
    do: assign(socket, :octave, shift_octave(socket.assigns.octave, -1))

  defp shift_octave(octave, amount) when octave + amount < 0, do: 0
  defp shift_octave(octave, amount) when octave + amount > 8, do: 8
  defp shift_octave(octave, amount), do: octave + amount

  defp play_note(socket, note, opts \\ [])

  defp play_note(socket, {note, octave}, opts) when is_atom(note) do
    play_note(socket, note, Keyword.put(opts, :octave, octave))
  end

  defp play_note(socket, note, opts) when is_atom(note) do
    track = Keyword.get(opts, :track, socket.assigns.selected_track)
    duration = Keyword.get(opts, :duration, "8n")

    octave =
      opts
      |> Keyword.get(:octave, socket.assigns.octave)

    # TODO:
    # tone_js_note = ToneJsNote.new(note, octave, duration)
    # to_string(note) # Cb3

    LiveTrackerWeb.Endpoint.broadcast!("tracker:playback", "play_note", %{
      track: track,
      note: to_string(note) <> to_string(octave),
      duration: duration
    })

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

  defp select_track(socket, track_id) when is_integer(track_id),
    do: assign(socket, :selected_track, track_id)

  defp select_track(socket, :prev),
    do: assign(socket, :selected_track, max(0, socket.assigns.selected_track - 1))

  defp select_track(socket, :next),
    do:
      assign(
        socket,
        :selected_track,
        min(socket.assigns.tracks - 1, socket.assigns.selected_track + 1)
      )

  ## Loop

  defp schedule_tick(socket) do
    time_in_ms = round(60 / socket.assigns.bpm * 1_000)
    Process.send_after(self(), :tick, time_in_ms)
    socket
  end

  def toggle_controls_view(%{assigns: %{controls_view: view}} = socket, view) do
    assign(socket, controls_view: "controls")
  end

  def toggle_controls_view(socket, view) do
    assign(socket, controls_view: view)
  end

  defp key_to_note("a", octave), do: {:C, octave}
  defp key_to_note("w", octave), do: {:Cb, octave}
  defp key_to_note("s", octave), do: {:D, octave}
  defp key_to_note("e", octave), do: {:Db, octave}
  defp key_to_note("d", octave), do: {:E, octave}
  defp key_to_note("f", octave), do: {:F, octave}
  defp key_to_note("t", octave), do: {:Fb, octave}
  defp key_to_note("g", octave), do: {:G, octave}
  defp key_to_note("y", octave), do: {:Gb, octave}
  defp key_to_note("h", octave), do: {:A, octave}
  defp key_to_note("u", octave), do: {:Ab, octave}
  defp key_to_note("j", octave), do: {:B, octave}
  defp key_to_note("k", octave), do: {:C, shift_octave(octave, 1)}
  defp key_to_note("m", _octave), do: :clear
end
