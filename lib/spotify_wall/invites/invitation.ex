defmodule SpotifyWall.Invitations.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invitations" do
    field :token, :string
    field :expires_at, :utc_datetime
    field :accepted_at, :utc_datetime
    field :revoked_at, :utc_datetime

    belongs_to :accepted_by, SpotifyWall.Accounts.User
    belongs_to :wall, SpotifyWall.Walls.Wall

    timestamps(type: :utc_datetime)
  end

  def revoke_changeset(invite) do
    change(invite, revoked_at: now())
  end

  def accept_changeset(invite, user) do
    invite
    |> change(%{accepted_at: now()})
    |> put_assoc(:accepted_by, user, required: true)
  end

  def create_changeset(wall, lifetime) do
    %__MODULE__{}
    |> change(token: Ecto.UUID.generate(), expires_at: calc_expiration(lifetime))
    |> put_assoc(:wall, wall, required: true)
    |> validate_required([:token, :expires_at])
    |> unique_constraint(:token)
  end

  defp calc_expiration(lifetime) do
    DateTime.utc_now() |> DateTime.add(lifetime, :second) |> DateTime.truncate(:second)
  end

  def now() do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
end
