defmodule SpotifyWall.Stats do
  import Ecto.Query
  alias SpotifyWall.Repo
  alias SpotifyWall.Walls.Wall
  alias SpotifyWall.Accounts.User

  def users_with_wall_count do
    query =
      from u in User,
        join: w in Wall,
        on: w.owner_id == u.id,
        group_by: u.id,
        order_by: u.inserted_at,
        select: {u, count(w.id)}

    Repo.all(query)
  end
end
