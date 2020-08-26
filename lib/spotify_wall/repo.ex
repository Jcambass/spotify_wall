defmodule SpotifyWall.Repo do
  use Ecto.Repo,
    otp_app: :spotify_wall,
    adapter: Ecto.Adapters.Postgres
end
