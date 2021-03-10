defmodule SpotifyWall.Repo.Migrations.AddPausedToMemberships do
  use Ecto.Migration

  def change do
    alter table(:memberships) do
      add :paused, :boolean, default: false, null: false
    end
  end
end
