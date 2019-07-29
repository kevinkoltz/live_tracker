defmodule LiveTracker.Repo do
  use Ecto.Repo,
    otp_app: :live_tracker,
    adapter: Ecto.Adapters.Postgres
end
