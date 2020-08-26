defmodule SpotifyWall.Repo.Migrations.AddRefreshTokenAndExpiresAtToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :refresh_token, :string
      add :expires_at, :timestamp
    end

    create index(:users, :expires_at)
  end
end
