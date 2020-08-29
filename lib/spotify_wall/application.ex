defmodule SpotifyWall.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SpotifyWall.Repo,
      # Start the Telemetry supervisor
      SpotifyWallWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SpotifyWall.PubSub},
      # Start the Endpoint (http/https)
      SpotifyWallWeb.Endpoint,
      # Start a worker by calling: SpotifyWall.Worker.start_link(arg)
      # {SpotifyWall.Worker, arg},
      {Oban, oban_config()},
      Spotify.ProcessRegistry,
      Spotify.Client,
      Spotify.Cache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SpotifyWall.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SpotifyWallWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Conditionally disable crontab, queues, or plugins here.
  defp oban_config do
    Application.get_env(:spotify_wall, Oban)
  end
end
