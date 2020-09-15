defmodule SpotifyWall.Walls.Wall do
  use Ecto.Schema
  import Ecto.Changeset

  schema "walls" do
    field :name, :string
    belongs_to :owner, SpotifyWall.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(wall, attrs) do
    wall
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255, count: :bytes)
  end
end
