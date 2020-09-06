defmodule SpotifyWallWeb.WallController do
  use SpotifyWallWeb, :controller

  alias SpotifyWall.Accounts

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, current_user) do
    walls = Accounts.get_walls_for_user(current_user)
    render(conn, "index.html", walls: walls)
  end

  def new(conn, _params, current_user) do
    render(conn, "new.html")
  end

  def create(conn, _params, current_user) do
    redirect(conn, to: Routes.wall_path(:index))
  end

  def edit(conn, _params, current_user) do
    render(conn, "edit.html")
  end

  def update(conn, _params, current_user) do
    redirect(conn, to: Routes.wall_path(:index))
  end

  def delete(conn, _params, current_user) do
    redirect(conn, to: Routes.wall_path(:index))
  end
end
