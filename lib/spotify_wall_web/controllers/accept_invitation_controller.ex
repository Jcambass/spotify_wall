defmodule SpotifyWallWeb.AcceptInvitationController do
  use SpotifyWallWeb, :controller

  alias SpotifyWall.Invitations
  alias SpotifyWall.Memberships

  plug :authenticate_user when action in [:accept]

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def show(conn, %{"id" => invitation_token}, current_user) do
    invitation = Invitations.get_by_token(invitation_token)

    if current_user do
      if Memberships.is_member?(invitation.wall, current_user) do
        render(conn, "show_already_member.html", invitation: invitation)
      else
        render(conn, "show.html", invitation: invitation)
      end
    else
      render(conn, "show_not_signed_in.html", invitation: invitation)
    end
  end

  def accept(conn, %{"id" => invitation_token}, current_user) do
    wall =
      Invitations.get_by_token(invitation_token)
      |> Invitations.accept!(current_user)

    redirect(conn, to: Routes.live_path(conn, SpotifyWallWeb.WallLive, wall.id))
  end
end
