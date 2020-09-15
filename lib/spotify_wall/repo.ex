defmodule SpotifyWall.Repo do
  use Ecto.Repo,
    otp_app: :spotify_wall,
    adapter: Ecto.Adapters.Postgres

  def print_query(query) do
    {query, params} = Ecto.Adapters.SQL.to_sql(:all, __MODULE__, query)
    IO.puts("#{query}, #{inspect(params)}")
  end
end
