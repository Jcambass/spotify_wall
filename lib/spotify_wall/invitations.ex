defmodule SpotifyWall.Invitations do
  # 24 hours
  @invitation_lifetime 24 * 60 * 60

  import Ecto.Query, warn: false

  alias SpotifyWall.Repo
  alias SpotifyWall.Invitations.Invitation
  alias SpotifyWall.Memberships
  alias SpotifyWall.Walls.Wall

  require Logger

  def create!(wall) do
    Logger.info("created_invitation", wall: %{id: wall.id})
    Invitation.create_changeset(wall, @invitation_lifetime)
    |> Repo.insert!()
  end

  def revoke!(invite) do
    Logger.info("revoked_invitation", invitation: %{id: invite.id})
    Invitation.revoke_changeset(invite)
    |> Repo.update!()
  end

  # TODO: Make this interface more logical
  def get_for_wall(%Wall{id: wall_id}, invite_id) do
    now = DateTime.utc_now()

    Repo.one!(
      from i in Invitation,
        where: i.wall_id == ^wall_id,
        where: i.id == ^invite_id,
        where: is_nil(i.revoked_at),
        where: is_nil(i.accepted_at),
        where: i.expires_at >= ^now
    )
  end

  def get_by_token(token) do
    now = DateTime.utc_now()

    Repo.one!(
      from i in Invitation,
        where: i.token == ^token,
        where: is_nil(i.revoked_at),
        where: is_nil(i.accepted_at),
        where: i.expires_at >= ^now
    )
    |> Repo.preload(:wall)
  end

  # TODO: Prevent accepting expired or revoked invitations!
  def accept!(invite, user) do
    Logger.info("accepted_invitation", invitation: %{id: invite.id}, user: %{id: user.id})
    invite =
      Repo.preload(invite, :accepted_by)
      |> Invitation.accept_changeset(user)
      |> Repo.update!()
      |> Repo.preload(:wall)

      # TODO: Unify behaviour so that we don't accept the invite if we're already an member.
      # Same would happen if the user is already logged in and tries to accept the invite and he's already an member.
    case Memberships.add_member(invite.wall, user) do
      {:error, :already_member} ->
        Logger.info("existing_member_accepted_invitation", invitation: %{id: invite.id}, user: %{id: user.id})
        invite.wall
      {:ok, wall} -> wall
    end
  end

  def list(%{id: wall_id}) do
    now = DateTime.utc_now()

    Repo.all(
      from i in Invitation,
        where: i.wall_id == ^wall_id,
        where: is_nil(i.revoked_at),
        where: is_nil(i.accepted_at),
        where: i.expires_at >= ^now
    )
  end
end
