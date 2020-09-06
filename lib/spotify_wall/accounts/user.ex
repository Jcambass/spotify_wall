defmodule SpotifyWall.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :nickname, :string
    field :token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime

    has_many :owned_walls, SpotifyWall.Accounts.Wall, foreign_key: :owner_id
    many_to_many :walls, SpotifyWall.Accounts.Wall, join_through: "memberships"

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:nickname, :token, :refresh_token, :expires_at])
    |> validate_required([:nickname, :token, :refresh_token, :expires_at])
    |> unique_constraint(:nickname)
  end
end
