defmodule SpotifyWall.Accounts.Wall do
  use Ecto.Schema
  import Ecto.Changeset

  schema "walls" do
    field :name, :string
    belongs_to :owner, SpotifyWall.Accounts.User
    many_to_many :users, SpotifyWall.Accounts.User, join_through: "memberships"

    timestamps(type: :utc_datetime)
  end

  def changeset(wall, attrs) do
    wall
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
