defmodule LiveTrackerWeb.Plugs.SetSession do
  @moduledoc """
  Generates a new session if one does already exist for the current user.
  """
  import Plug.Conn

  alias LiveTracker.Sessions.{Session, SessionStore}

  def init(_params) do
  end

  def call(conn, _opts) do
    session_id = get_session(conn, :session_id)

    case SessionStore.get(session_id) do
      {:ok, session} ->
        conn

      {:error, :not_found} ->
        {:ok, session} =
          Session.new()
          |> SessionStore.insert()

        put_session(conn, :session_id, session.id)
    end
  end
end
