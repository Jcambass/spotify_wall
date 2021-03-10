defmodule SpotifyWall.Memberships do
  import Ecto.Query, warn: false

  alias SpotifyWall.Repo
  alias SpotifyWall.Walls.Wall
  alias SpotifyWall.Memberships.Membership
  alias SpotifyWall.Accounts.User
  alias SpotifyWall.Spotify.Session

  require Logger

  def add_member(wall, user) do
    Logger.info("add_member_to_wall", wall: %{id: wall.id}, user: %{id: user.id})

    case Membership.add_member_changeset(wall, user) |> Repo.insert() do
      {:ok, _membership} ->
        {:ok, wall}

      {:error,
       %{
         errors: [
           user_id:
             {"has already been taken",
              [constraint: :unique, constraint_name: "memberships_wall_id_user_id_index"]}
         ]
       }} ->
        Logger.info("already_member_of_wall", wall: %{id: wall.id}, user: %{id: user.id})
        {:error, :already_member}

      error ->
        error
    end
  end

  # TODO: Prevent removing the owner of the wall.
  def remove_member!(wall, user) do
    Logger.info("remove_member_from_wall", wall: %{id: wall.id}, user: %{id: user.id})

    Repo.get_by!(Membership, wall_id: wall.id, user_id: user.id)
    |> Repo.delete!()
  end

  def pause_membership!(wall, user) do
    Logger.info("paused_membership", wall: %{id: wall.id}, user: %{id: user.id})

    get_membership(wall, user)
    |> Membership.pause_changeset(true)
    |> Repo.update!()

    Session.broadcast(user.nickname, {:membership_paused, user})
  end

  def resume_membership!(wall, user) do
    Logger.info("resumed_membership", wall: %{id: wall.id}, user: %{id: user.id})

    get_membership(wall, user)
    |> Membership.pause_changeset(false)
    |> Repo.update!()

    Session.broadcast(user.nickname, {:membership_resumed, user})
  end

  def is_member?(%Wall{id: wall_id}, %User{id: user_id}) do
    Repo.exists?(
      from mem in Membership,
        where: mem.wall_id == ^wall_id,
        where: mem.user_id == ^user_id
    )
  end

  def get_members(%Wall{id: wall_id}) do
    query =
      from mem in Membership,
        where: mem.wall_id == ^wall_id

    Repo.all(query)
    |> Repo.preload(:user)
  end

  def get_membership(%Wall{id: wall_id}, %User{id: user_id}) do
    Repo.one(
      from mem in Membership,
        where: mem.wall_id == ^wall_id,
        where: mem.user_id == ^user_id
    )
  end
end
