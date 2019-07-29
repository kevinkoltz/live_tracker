defmodule LiveTrackerWeb.PageController do
  use LiveTrackerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
