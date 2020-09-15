defmodule SpotifyWall.Walls do
  import Ecto.Query, warn: false
  alias SpotifyWall.Repo
  alias SpotifyWall.Accounts.User
  alias SpotifyWall.Walls.Wall
  alias SpotifyWall.Memberships
  alias SpotifyWall.Memberships.Membership

  require Logger

  def create(user, name) do
    wall =
      %Wall{}
      |> Wall.changeset(%{name: name})
      |> Ecto.Changeset.put_assoc(:owner, user, required: true)
    |> Repo.insert()

    case wall do
      {:ok, wall} ->
        Logger.info("created_wall", wall: %{id: wall.id, name: name}, owner: %{id: user.id})
        Memberships.add_member(wall, user)
      res -> res
    end
  end

  def update!(wall, name) do
    Logger.info("updated_wall", wall: %{id: wall.id, new_name: name})
    wall
    |> Wall.changeset(%{name: name})
    |> Repo.update()
  end

  def delete!(wall) do
    Logger.info("deleted_wall", wall: %{id: wall.id})
    Repo.delete!(wall)
  end

  def get_owned_wall!(%User{id: user_id}, wall_id) do
    query =
      from w in Wall,
        where: w.owner_id == ^user_id,
        where: w.id == ^wall_id

    Repo.one!(query)
    |> Repo.preload(:owner)
  end

  def get_walls(user) do
    user =
      user
      |> Repo.preload(:walls)
      |> Repo.preload(walls: :owner)

    user.walls
  end

  def get_wall!(%User{id: user_id}, wall_id) do
    query =
      from w in Wall,
        join: mem in Membership,
        on: mem.wall_id == w.id,
        where: mem.user_id == ^user_id,
        where: w.id == ^wall_id

    Repo.one!(query)
  end
end
