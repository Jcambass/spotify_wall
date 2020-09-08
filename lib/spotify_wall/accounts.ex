defmodule SpotifyWall.Accounts do
  @moduledoc """
  The Accounts context.
  """

  # 20 minutes
  @refresh_tokens_expiring_in 20 * 60

  import Ecto.Query, warn: false
  alias SpotifyWall.Repo

  alias SpotifyWall.Accounts.User
  alias SpotifyWall.Accounts.Wall
  alias SpotifyWall.Accounts.Membership

  # TODO: Cleanup and split context!

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_nickname!(nickname), do: Repo.get_by!(User, nickname: nickname)

  def upsert_user(nickname, token, refresh_token, expires_at) do
    attrs = %{
      nickname: nickname,
      token: token,
      refresh_token: refresh_token,
      expires_at: DateTime.from_unix!(expires_at)
    }

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!(
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: :nickname,
      returning: true
    )
  end

  def create_wall!(user, name) do
    wall = %Wall{}
    |> Wall.changeset(%{name: name})
    |> Ecto.Changeset.put_assoc(:owner, user, required: true)
    |> Repo.insert

    case wall do
      {:ok, wall} -> {:ok, add_user_to_wall(wall, user)}
      res -> res
    end
  end

  def update_wall!(wall, name) do
    wall
    |> Wall.changeset(%{name: name})
    |> Repo.update
  end

  def get_walls_for_user(user) do
    user = user
    |> Repo.preload(:walls)
    |> Repo.preload(walls: :owner)
    user.walls
  end

  def get_wall_for_owner!(%User{id: user_id}, wall_id) do
    query = from w in Wall,
      where: w.owner_id == ^user_id,
      where: w.id == ^wall_id

    Repo.one!(query)
    |> Repo.preload(:owner)
  end

  def get_wall!(%User{id: user_id}, wall_id) do
    query = from w in Wall,
      join: mem in Membership, on: mem.wall_id == w.id,
      where: mem.user_id == ^user_id,
      where: w.id == ^wall_id

    Repo.one!(query)
  end

  def delete_wall!(wall) do
    Repo.delete!(wall)
  end

  def get_users_for_wall(wall) do
    wall = Repo.preload(wall, :users)
    wall.users
  end

  def get_members(%Wall{id: wall_id}) do
    query = from mem in Membership,
      where: mem.wall_id == ^wall_id

    Repo.all(query)
    |> Repo.preload(:user)
  end

  # TODO: Move to something like accept_invite.
  def add_user_to_wall(wall, user) do
    {:ok, _} = %Membership{}
    |> Membership.changeset(%{})
    |> Ecto.Changeset.put_assoc(:wall, wall)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert

    wall
  end

  # TODO: Prevent removing the owner of the wall.
  def remove_user_from_wall!(wall, user) do
    Repo.get_by!(Membership, wall_id: wall.id, user_id: user.id)
    |> Repo.delete!
  end

  def invite_user_to_wall(wall, user) do
  end

  # TODO: Probably remove me!
  def list_users do
    Repo.all(User)
  end

  def update_user_token(user, token, expires_in) do
    expires_at = DateTime.add(DateTime.truncate(DateTime.utc_now(), :second), expires_in)

    User.changeset(user, %{token: token, expires_at: expires_at})
    |> Repo.update!()
  end

  def list_expiring_users do
    expiration_time = DateTime.add(DateTime.utc_now(), @refresh_tokens_expiring_in)

    Repo.all(
      from u in User,
        where: u.expires_at <= ^expiration_time
    )
  end

  # TODO: allow unconnecting and deleting user.
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end
end
