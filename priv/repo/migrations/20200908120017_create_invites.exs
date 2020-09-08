defmodule SpotifyWall.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invitations) do
      add :token, :string, null: false
      add :accepted_by_id, references(:users, on_delete: :delete_all)
      add :expires_at, :timestamp
      add :accepted_at, :timestamp
      add :revoked_at, :timestamp
      add :wall_id, references(:walls, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:invitations, :token)
  end
end
