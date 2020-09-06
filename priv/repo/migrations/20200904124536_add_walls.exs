defmodule SpotifyWall.Repo.Migrations.AddWalls do
  use Ecto.Migration

  def change do
    create table(:walls) do
      add :name, :string, null: false
      add :owner_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
