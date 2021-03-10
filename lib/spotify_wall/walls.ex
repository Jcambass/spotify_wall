defmodule SpotifyWall.Walls do
  import Ecto.Query, warn: false
  alias SpotifyWall.Repo
  alias SpotifyWall.Accounts.User
  alias SpotifyWall.Walls.Wall
  alias SpotifyWall.Memberships
  alias SpotifyWall.Memberships.Membership

  require Logger

  def create(user, name) do
    case Wall.create_changeset(user, %{name: name}) |> Repo.insert() do
      {:ok, wall} ->
        Logger.info("created_wall", wall: %{id: wall.id, name: name}, owner: %{id: user.id})
        Memberships.add_member(wall, user)

      res ->
        res
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

  def get_accessible_walls(user) do
    user =
      user
      |> Repo.preload(
        memberships: {from(mem in Membership, order_by: mem.inserted_at), [wall: :owner]}
      )

    user.memberships
  end

  def get_wall!(%User{id: user_id}, wall_id) do
    query =
      from w in Wall,
        join: mem in Membership,
        on: mem.wall_id == w.id,
        where: mem.user_id == ^user_id,
        where: w.id == ^wall_id

    Repo.one!(query) |> Repo.preload(:owner)
  end
end
