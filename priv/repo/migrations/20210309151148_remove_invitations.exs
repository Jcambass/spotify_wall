defmodule SpotifyWall.Repo.Migrations.RemoveInvitations do
  use Ecto.Migration

  def change do
    drop table(:invitations)
  end
end
