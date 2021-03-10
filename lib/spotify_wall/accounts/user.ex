defmodule SpotifyWall.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :nickname, :string
    field :token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime

    has_many :memberships, SpotifyWall.Memberships.Membership

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:nickname, :token, :refresh_token, :expires_at])
    |> validate_required([:nickname, :token, :refresh_token, :expires_at])
    |> unique_constraint(:nickname)
  end
end
