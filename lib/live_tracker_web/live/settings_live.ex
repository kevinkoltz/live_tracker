defmodule LiveTrackerWeb.SettingsLive do
  @moduledoc false
  use Phoenix.LiveView

  alias LiveTracker.{Sessions, Themes}
  alias LiveTracker.Sessions.{Session, SessionStore}
  alias LiveTrackerWeb.{GlobalView, SettingsView}
  alias LiveTrackerWeb.Router.Helpers, as: Routes

  def render(assigns), do: SettingsView.render("index.html", assigns)

  def mount(%{session_id: session_id} = _session, socket) do
    {:ok, session} = SessionStore.get(session_id)

    changeset =
      session
      |> Sessions.change_session(%{
        username: Sessions.generate_username()
      })

    themes = Themes.list_themes()

    {:ok,
     socket
     |> assign(themes: themes)
     |> assign(changeset: changeset)
     |> assign(selected_theme: changeset.data.theme)}
  end

  def handle_event("change_theme", slug, socket) do
    case Themes.get_theme(slug) do
      nil ->
        {:stop,
         socket
         |> put_flash(:error, "Invalid theme: #{inspect(slug)}")
         |> redirect(to: Routes.live_path(socket, __MODULE__))}

      theme ->
        {:noreply, assign(socket, selected_theme: theme.slug)}
    end
  end

  def handle_event("generate_handle", _, socket) do
    changeset =
      socket.assigns.changeset
      |> Sessions.change_session(%{
        username: Sessions.generate_username()
      })

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("change", %{"session" => params}, socket) do
    updated_socket =
      socket
      |> validate_changeset(params)
      |> select_theme(params)

    {:noreply, updated_socket}
  end

  def handle_event("save", %{"session" => session_params}, socket) do
    case Sessions.create_session(socket.assigns.changeset, session_params) do
      {:ok, session} ->
        {:stop, redirect(socket, to: "/?song_id=#{session.current_song_id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp validate_changeset(socket, params) do
    changeset =
      socket.assigns.changeset
      |> Sessions.change_session(params)

    assign(socket, changeset: changeset)
  end

  defp select_theme(socket, %{"theme" => theme}) do
    assign(socket, selected_theme: theme)
  end
end
