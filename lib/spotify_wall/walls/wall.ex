defmodule SpotifyWall.Walls.Wall do
  use Ecto.Schema
  import Ecto.Changeset

  schema "walls" do
    field :name, :string
    field :join_token, :string
    belongs_to :owner, SpotifyWall.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def create_changeset(owner, attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> put_assoc(:owner, owner, required: true)
    |> change(join_token: SpotifyWall.Memberships.generate_join_token())
  end

  def changeset(wall, attrs) do
    wall
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255, count: :bytes)
  end
end
