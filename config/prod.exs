use Mix.Config

gigalixir_host = System.get_env("APP_NAME") && System.get_env("APP_NAME") <> ".gigalixirapp.com"
render_host = System.get_env("RENDER_EXTERNAL_HOSTNAME")
host = render_host || gigalixir_host || "localhost"

config :live_tracker, LiveTrackerWeb.Endpoint,
  # url: [host: System.get_env("RENDER_EXTERNAL_HOSTNAME") || "localhost", port: 80],
  url: [host: host, port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :debug
