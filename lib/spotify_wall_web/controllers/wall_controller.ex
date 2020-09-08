defmodule SpotifyWallWeb.WallController do
  use SpotifyWallWeb, :controller

  alias SpotifyWall.Accounts
  alias SpotifyWall.Accounts.Wall

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, current_user) do
    walls = Accounts.get_walls_for_user(current_user)
    render(conn, "index.html", walls: walls)
  end

  def new(conn, _params, current_user) do
    changeset = Wall.changeset(%Wall{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"wall" => %{"name" => name}}, current_user) do
    case Accounts.create_wall!(current_user, name) do
      {:ok, _wall} -> redirect(conn, to: Routes.wall_path(conn, :index))
      {:error, changeset} -> render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => wall_id}, current_user) do
    wall = Accounts.get_wall_for_owner!(current_user, wall_id)
    changeset = Wall.changeset(wall, %{})
    memberships = Accounts.get_members(wall)
    render(conn, "edit.html", changeset: changeset, wall: wall, memberships: memberships)
  end

  def update(conn, %{"id" => wall_id, "wall" => %{"name" => name}}, current_user) do
    wall = Accounts.get_wall_for_owner!(current_user, wall_id)
    case Accounts.update_wall!(wall, name) do
      {:ok, _wall} -> redirect(conn, to: Routes.wall_path(conn, :index))
      {:error, changeset} ->
        memberships = Accounts.get_members(wall)
        render(conn, "edit.html", changeset: changeset, memberships: memberships, wall: wall)
    end
  end

  def delete(conn, %{"id" => wall_id}, current_user) do
    # TODO: Add modal
    # TODO: Add flash message!
    wall = Accounts.get_wall_for_owner!(current_user, wall_id)
    Accounts.delete_wall!(wall)
    redirect(conn, to: Routes.wall_path(conn, :index))
  end
end
