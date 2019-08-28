defmodule LiveTracker.Sessions.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(LiveTracker.Sessions.SessionStore, [[name: LiveTracker.Sessions.SessionStore]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
