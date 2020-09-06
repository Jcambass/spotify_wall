defmodule SpotifyWall.Accounts.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "memberships" do
    belongs_to :user, SpotifyWall.Accounts.User
    belongs_to :wall, SpotifyWall.Accounts.Wall

    timestamps(type: :utc_datetime)
  end

  def changeset(membership, attrs) do
    membership
    |> change
    |> unique_constraint([:user_id, :wall_id])
  end
end
