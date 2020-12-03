# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :spotify_wall,
  ecto_repos: [SpotifyWall.Repo]

# Configures the endpoint
config :spotify_wall, SpotifyWallWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "OmC87QVj/eEQSuRAFIGUQn9+UDOGikgOhnyGV9upSorEYoV9d2DT/tFYBkXfon3b",
  render_errors: [view: SpotifyWallWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SpotifyWall.PubSub,
  live_view: [signing_salt: "WLTf7uio"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    spotify: {Ueberauth.Strategy.Spotify, [default_scope: "user-read-currently-playing"]}
  ]

config :ueberauth, Ueberauth.Strategy.Spotify.OAuth,
  client_id: System.get_env("SPOTIFY_CLIENT_ID"),
  client_secret: System.get_env("SPOTIFY_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
