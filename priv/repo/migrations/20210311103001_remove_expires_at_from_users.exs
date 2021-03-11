defmodule SpotifyWall.Repo.Migrations.RemoveExpiresAtFromUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :expires_at
    end
  end
end
