defmodule SpotifyWallWeb.MembershipController do
  use SpotifyWallWeb, :controller
  alias SpotifyWall.Memberships
  alias SpotifyWall.Walls
  alias SpotifyWall.Accounts.User

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def delete(conn, %{"wall_id" => wall_id, "id" => user_id}, current_user) do
    # TODO: Add support so that current_user can remove themself from the wall.
    wall = Walls.get_owned_wall!(current_user, wall_id)
    # TODO: Add flash
    if current_user.id == user_id do
      redirect(conn, to: Routes.wall_path(conn, :edit, wall.id))
    else
      Memberships.remove_member!(wall, %User{id: user_id})
      redirect(conn, to: Routes.wall_path(conn, :edit, wall.id))
    end
  end

  def pause(conn, %{"wall_id" => wall_id}, current_user) do
    wall = Walls.get_wall!(current_user, wall_id)
    Memberships.pause_membership!(wall, current_user)
    redirect(conn, to: Routes.wall_path(conn, :index))
  end

  def resume(conn, %{"wall_id" => wall_id}, current_user) do
    wall = Walls.get_wall!(current_user, wall_id)
    Memberships.resume_membership!(wall, current_user)
    redirect(conn, to: Routes.wall_path(conn, :index))
  end
end
