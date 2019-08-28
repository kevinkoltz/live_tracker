defmodule LiveTrackerWeb.Router do
  use LiveTrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Phoenix.LiveView.Flash
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug LiveTrackerWeb.Plugs.SetSession
  end

  pipeline :require_session do
    plug LiveTrackerWeb.Plugs.RequireValidSession
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveTrackerWeb do
    pipe_through :browser
    pipe_through :require_session

    live "/", SequencerLive, session: [:session_id]
  end

  scope "/", LiveTrackerWeb do
    pipe_through :browser

    live "/settings", SettingsLive, session: [:session_id]
  end
end
