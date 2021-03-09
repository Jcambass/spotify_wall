defmodule SpotifyWall.Repo.Migrations.AddJoinLinkToWalls do
  use Ecto.Migration

  def up do
    alter table(:walls) do
      add :join_token, :string
    end
    create unique_index(:walls, :join_token)

    flush()

    SpotifyWall.Repo.all(SpotifyWall.Walls.Wall)
    |> Enum.each(&SpotifyWall.Join.revoke_token!/1)

    # NOTE: Not safe with large amount of data but totaly ok when you have no users anyway..
    alter table(:walls) do
      modify :join_token, :string, null: false
    end
  end

  def down do
    alter table(:walls) do
      remove :join_token
    end

    drop index(:walls, :join_token)
  end
end
