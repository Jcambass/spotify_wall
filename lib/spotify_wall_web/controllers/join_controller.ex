defmodule SpotifyWallWeb.JoinController do
  use SpotifyWallWeb, :controller

  alias SpotifyWall.Memberships

  plug :authenticate_user when action in [:accept]

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def show(conn, %{"id" => join_token}, current_user) do
    wall = Memberships.get_wall_by_token!(join_token)

    if current_user do
      if Memberships.is_member?(wall, current_user) do
        render(conn, "show_already_member.html", wall: wall)
      else
        render(conn, "show.html", wall: wall)
      end
    else
      render(conn, "show_not_signed_in.html", wall: wall)
    end
  end

  def accept(conn, %{"id" => join_token}, current_user) do
    wall = Memberships.get_wall_by_token!(join_token)

    case Memberships.add_member(wall, current_user) do
      {:error, :already_member} ->
        redirect(conn, to: Routes.join_path(conn, :show, wall.join_token))

      {:ok, wall} ->
        redirect(conn, to: Routes.live_path(conn, SpotifyWallWeb.WallLive, wall.id))
    end
  end
end
