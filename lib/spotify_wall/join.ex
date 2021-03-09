defmodule SpotifyWall.Join do
  alias SpotifyWall.Repo
  alias SpotifyWall.Walls.Wall
  import Ecto.Query

  require Logger

  def get_wall_by_token!(join_token) do
    query =
      from w in Wall,
        where: w.join_token == ^join_token

    Repo.one!(query)
  end

  def revoke_token!(wall) do
    Logger.info("revoked_join_token", wall: %{id: wall.id})

    Ecto.Changeset.change(wall, join_token: generate_join_token())
    |> Repo.update!()
  end

  def generate_join_token() do
    Nanoid.generate()
  end
end
