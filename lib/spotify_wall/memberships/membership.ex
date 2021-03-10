defmodule SpotifyWall.Memberships.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "memberships" do
    belongs_to :user, SpotifyWall.Accounts.User
    belongs_to :wall, SpotifyWall.Walls.Wall
    field :paused, :boolean

    timestamps(type: :utc_datetime)
  end

  def add_member_changeset(wall, user) do
    %__MODULE__{}
    |> change()
    |> unique_constraint(:user_id, name: :memberships_wall_id_user_id_index)
    |> Ecto.Changeset.put_assoc(:wall, wall)
    |> Ecto.Changeset.put_assoc(:user, user)
  end

  def pause_changeset(membership, paused) do
    membership
    |> change(paused: paused)
  end
end
