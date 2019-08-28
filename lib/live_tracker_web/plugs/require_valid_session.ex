defmodule LiveTrackerWeb.Plugs.RequireValidSession do
  @moduledoc """
  Requires the current user to select an username for a newly generated session.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias LiveTracker.Sessions
  alias LiveTracker.Sessions.SessionStore

  def init(_params) do
  end

  def call(conn, _params) do
    {:ok, session} =
      conn
      |> get_session(:session_id)
      |> SessionStore.get()

    if Sessions.valid_session?(session) do
      conn
    else
      conn
      |> redirect(to: "/settings")
      |> halt()
    end
  end
end
