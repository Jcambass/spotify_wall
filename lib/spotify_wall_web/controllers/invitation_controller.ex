defmodule SpotifyWallWeb.InvitationController do
  use SpotifyWallWeb, :controller

  alias SpotifyWall.Invitations
  alias SpotifyWall.Walls

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def create(conn, %{"wall_id" => wall_id}, current_user) do
    Walls.get_owned_wall!(current_user, wall_id)
    |> Invitations.create!()

    redirect(conn, to: Routes.wall_path(conn, :edit, wall_id))
  end

  def delete(conn, %{"wall_id" => wall_id, "id" => invitation_id}, current_user) do
    Walls.get_owned_wall!(current_user, wall_id)
    |> Invitations.get_for_wall(invitation_id)
    |> Invitations.revoke!()

    redirect(conn, to: Routes.wall_path(conn, :edit, wall_id))
  end
end
