use Mix.Config

gigalixir_host = System.get_env("APP_NAME") && System.get_env("APP_NAME") <> ".gigalixirapp.com"
render_host = System.get_env("RENDER_EXTERNAL_HOSTNAME")
host = render_host || gigalixir_host || "localhost"

config :live_tracker, LiveTrackerWeb.Endpoint,
  # http: [port: {:system, "PORT"}],
  url: [host: host, port: 80],
  # secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE"),
  cache_static_manifest: "priv/static/cache_manifest.json"
  # server: true

config :logger, level: :debug
