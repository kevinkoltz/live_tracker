defmodule LiveTrackerWeb.SequencerLive do
  use Phoenix.LiveView

  @initial bpm: 120,
           playing: false,
           recording: false,
           position: 1,
           length: 16,
           sequence: %{
             1 => %{notes: ["A4"]},
             2 => %{notes: ["B4"]},
             3 => %{notes: ["C4"]},
             4 => %{notes: ["D4"]},
             5 => %{notes: ["E4"]},
             6 => %{notes: ["C4"]},
             7 => %{notes: ["E4"]},
             8 => %{notes: [""]},
             9 => %{notes: ["Db4"]},
             10 => %{notes: ["B4"]},
             11 => %{notes: ["Db4"]},
             12 => %{notes: [""]},
             13 => %{notes: ["D4"]},
             14 => %{notes: ["B4"]},
             15 => %{notes: ["D4"]},
             16 => %{notes: [""]}
           }

  def render(assigns) do
    ~L"""
    Position: <%= @position %>

    <div>
      <button phx-click="record">Record</button>
      <button phx-click="play">Play</button>
      <button phx-click="stop">Stop</button>
    </div>

    <%= inspect(assigns) %>
    """
  end

  def mount(_session, socket) do
    updated_socket = assign(socket, @initial)

    if connected?(socket) do
      schedule_tick(updated_socket)
    end

    {:ok, updated_socket}
  end

  def handle_event("play", _, socket), do: {:noreply, play(socket)}
  def handle_event("stop", _, socket), do: {:noreply, stop(socket)}
  def handle_event("record", _, socket), do: {:noreply, record(socket)}

  # def handle_event(event, message, socket) do
  #   IO.inspect({event, message}, label: "event not handled")
  #   {:noreply, socket}
  # end

  def handle_info(:tick, socket) do
    IO.inspect(socket.assigns.position, label: "tock")
    {:noreply, socket |> schedule_tick() |> advance()}
  end

  defp advance(%{assigns: %{playing: false}} = socket), do: socket
  defp advance(%{assigns: %{position: n, length: n}} = socket), do: reset_position(socket)
  defp advance(socket), do: update(socket, :position, &(&1 + 1))

  defp play(socket), do: assign(socket, playing: true)

  defp stop(%{assigns: %{playing: false, position: position}} = socket) when position > 1 do
    socket
    |> reset_position()
    |> stop()
  end

  defp stop(socket), do: assign(socket, playing: false, recording: false)

  defp record(%{assigns: %{playing: false}} = socket),
    do: socket |> assign(recording: true) |> play()

  defp record(%{assigns: %{playing: true}} = socket), do: assign(socket, recording: false)

  defp reset_position(socket), do: socket |> IO.inspect() |> assign(position: 1)

  defp schedule_tick(socket) do
    time_in_ms = round(60 / socket.assigns.bpm * 1_000)
    Process.send_after(self(), :tick, time_in_ms)
    socket
  end
end
