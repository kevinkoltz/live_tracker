defmodule LiveTrackerWeb.SequencerLive do
  @moduledoc false
  use Phoenix.LiveView

  alias LiveTracker.Clock
  alias LiveTracker.Sessions.SessionStore
  alias LiveTracker.Tunes
  alias LiveTracker.Tunes.Tune
  alias LiveTrackerWeb.Router.Helpers, as: Routes
  alias LiveTrackerWeb.SequencerView

  @initial bpm: 200,
           playing: false,
           recording: false,
           song_position: 0,
           pattern: 254,
           pattern_length: 16,
           pattern_step: 0,
           tracks: 4,
           selected_track: 1,
           octave: 4,
           current_note: nil,
           options_view: "options",
           tunes: [],
           tune: Tune.new("FF"),
           load_file_selected_id: nil,
           theme: "elixir"

  def render(assigns), do: SequencerView.render("index.html", assigns)

  def mount(%{session_id: session_id} = _session, socket) do
    {:ok, session} = SessionStore.get(session_id)

    updated_socket =
      socket
      |> assign(@initial)
      |> assign(theme: session.theme)
      |> assign(username: session.username)
      # TODO: update this to be an instance of a song (song session id)
      |> assign(current_song_id: session.current_song_id)
      |> assign(stunes: Tunes.list_tunes())

    if connected?(socket) do
      Tunes.subscribe("clock:#{session.current_song_id}")

      if Clock.lookup_pid(session.current_song_id) == nil do
        Clock.start_link(session.current_song_id, bpm: @initial[:bpm])
      end
    end

    {:ok, updated_socket}
  end

  ## Transport

  def handle_event("play", _, socket), do: {:noreply, play(socket)}
  def handle_event("stop", _, socket), do: {:noreply, stop(socket)}
  def handle_event("record", _, socket), do: {:noreply, record(socket)}

  ## Tracks

  def handle_event("select_track", track_id, socket),
    do: {:noreply, select_track(socket, String.to_integer(track_id))}

  def handle_event("keydown", "ArrowRight", socket), do: {:noreply, select_track(socket, :next)}
  def handle_event("keydown", "ArrowLeft", socket), do: {:noreply, select_track(socket, :prev)}

  ## Keyboard notes

  # TODO: this should temporarily overwrite tune so both notes do not clobber each other

  def handle_event("keydown", key, socket)
      when key in ["a", "w", "s", "e", "d", "f", "t", "g", "y", "h", "u", "j", "m"] do
    %{octave: octave, pattern_step: pattern_step, selected_track: selected_track} = socket.assigns

    note = key_to_note(key, octave)

    # TODO: debounce to prevent duplicate repeated notes, quantize amount of
    # time to duration between steps?
    send(self(), {:maybe_record, note, selected_track, pattern_step})

    {:noreply, play_note(socket, note)}
  end

  ## Octave up/down

  def handle_event("keydown", "z", socket), do: {:noreply, change_octave(socket, :down)}
  def handle_event("keydown", "x", socket), do: {:noreply, change_octave(socket, :up)}

  def handle_event("keydown", _keydown, socket), do: {:noreply, socket}

  ## Options Views

  def handle_event("toggle_options_view", view, socket)
      when view in [
             "load",
             "save",
             "upload",
             "scale",
             "theme",
             "instrument_edit",
             "pattern_edit",
             "sample_edit",
             "options"
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
        {:noreply, toggle_options_view(socket, view)}

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
    {:noreply, assign(socket, tune: Tune.new("FF"))}
  end

  def handle_event("load", _, socket) do
    id = socket.assigns.load_file_selected_id

    # TODO: load from saved tunes
    case Tunes.load_tune(id) do
      {:ok, tune} ->
        {:noreply,
         socket
         |> assign(tune: tune)
         |> toggle_options_view("load")}

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

  def handle_event("settings", _, socket) do
    # TODO: Prompt to save
    {:stop, redirect(socket, to: Routes.live_path(socket, LiveTrackerWeb.SettingsLive))}
  end

  def handle_info({:clock, clock}, socket) do
    pattern_step = rem(clock.song_position, socket.assigns.pattern_length)

    {:noreply,
     socket
     |> assign(Map.take(clock, [:bpm, :playing, :time, :song_position]))
     |> assign(pattern_step: pattern_step)
     |> maybe_play_notes()}
  end

  def handle_info({:maybe_record, _, _, _}, %{assigns: %{recording: false}} = socket) do
    {:noreply, socket}
  end

  def handle_info(
        {:maybe_record, note, track, pattern_step},
        %{assigns: %{recording: true}} = socket
      ) do
    tune =
      socket.assigns.tune
      |> Tunes.record_note(note, track, pattern_step)

    {:noreply, socket |> assign(tune: tune)}
  end

  ## Transport

  defp play(socket) do
    Clock.play(socket.assigns.current_song_id)
    socket
  end

  defp stop(socket) do
    Clock.stop(socket.assigns.current_song_id)
    assign(socket, recording: false)
  end

  defp record(%{assigns: %{recording: true, playing: true}} = socket),
    do: socket |> toggle_recording() |> stop()

  defp record(%{assigns: %{recording: false, playing: false}} = socket),
    do: socket |> toggle_recording() |> play()

  defp record(%{assigns: %{recording: false, playing: true}} = socket),
    do: socket |> toggle_recording()

  defp toggle_recording(socket), do: assign(socket, recording: !socket.assigns.recording)

  ## Notes

  defp maybe_play_notes(%{assigns: %{playing: true}} = socket) do
    %{tune: tune, tracks: tracks, pattern_step: pattern_step} = socket.assigns

    for track <- 0..(tracks - 1) do
      note = Map.get(tune.notes, {track, pattern_step})

      if note do
        play_note(socket, note, track: track)
      end
    end

    socket
  end

  defp maybe_play_notes(%{assigns: %{playing: false}} = socket), do: socket

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

  def toggle_options_view(%{assigns: %{options_view: view}} = socket, view) do
    assign(socket, options_view: "options")
  end

  def toggle_options_view(socket, view) do
    assign(socket, options_view: view)
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
