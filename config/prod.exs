use Mix.Config

if System.get_env("RENDER_EXTERNAL_HOSTNAME") do
  # Render config
  config :live_tracker, LiveTrackerWeb.Endpoint,
    url: [host: "livetracker.kevinkoltz.com", port: 80],
    cache_static_manifest: "priv/static/cache_manifest.json"
else
  # Gigalixir config (old config)
  config :live_tracker, LiveTrackerWeb.Endpoint,
    http: [port: {:system, "PORT"}],
    url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 80],
    secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE"),
    cache_static_manifest: "priv/static/cache_manifest.json",
    server: true
end

config :logger, level: :debug
