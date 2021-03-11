defmodule SpotifyWall.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :nickname, :string
    field :refresh_token, :string

    has_many :memberships, SpotifyWall.Memberships.Membership

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:nickname, :refresh_token])
    |> validate_required([:nickname, :refresh_token])
    |> unique_constraint(:nickname)
  end
end
