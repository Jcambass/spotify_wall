defmodule SpotifyWall.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :nickname, :string
      add :token, :string

      timestamps()
    end

    unique_index(:users, :nickname)
  end
end
