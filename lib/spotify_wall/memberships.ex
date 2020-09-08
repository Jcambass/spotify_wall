defmodule SpotifyWall.Memberships do
  import Ecto.Query, warn: false

  alias SpotifyWall.Repo
  alias SpotifyWall.Walls.Wall
  alias SpotifyWall.Memberships.Membership
  alias SpotifyWall.Accounts.User

  def add_member(wall, user) do
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
        {:error, :already_member}

      error ->
        error
    end
  end

  # TODO: Prevent removing the owner of the wall.
  def remove_member!(wall, user) do
    Repo.get_by!(Membership, wall_id: wall.id, user_id: user.id)
    |> Repo.delete!()
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
end
