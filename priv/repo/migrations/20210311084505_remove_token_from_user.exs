defmodule SpotifyWall.Repo.Migrations.RemoveTokenFromUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :token
    end
  end
end
