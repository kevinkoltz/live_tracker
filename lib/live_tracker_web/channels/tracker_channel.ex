defmodule LiveTrackerWeb.TrackerChannel do
  @moduledoc """
  Channel for playing music with Tone.js.
  """
  use Phoenix.Channel

  def join("tracker:" <> _subtopic, _payload, socket) do
    # IO.inspect(track_id, label: "joined track_id")
    # IO.inspect({payload, socket}, label: "{payload, socket}")
    {:ok, socket}
  end
end
