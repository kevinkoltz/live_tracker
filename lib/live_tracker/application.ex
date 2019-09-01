defmodule LiveTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias LiveTrackerWeb.Endpoint

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: LiveTracker.ClockRegistry},
      LiveTracker.Sessions.Supervisor,
      LiveTrackerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
