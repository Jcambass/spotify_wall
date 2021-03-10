defmodule SpotifyWallWeb.WallController do
  use SpotifyWallWeb, :controller

  alias SpotifyWall.Walls
  alias SpotifyWall.Walls.Wall
  alias SpotifyWall.Memberships
  alias SpotifyWall.Join

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, current_user) do
    memberships = Walls.get_accessible_walls(current_user)
    render(conn, "index.html", memberships: memberships)
  end

  def new(conn, _params, _current_user) do
    changeset = Wall.changeset(%Wall{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"wall" => %{"name" => name}}, current_user) do
    case Walls.create(current_user, name) do
      {:ok, _wall} -> redirect(conn, to: Routes.wall_path(conn, :index))
      {:error, changeset} -> render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => wall_id}, current_user) do
    wall = Walls.get_owned_wall!(current_user, wall_id)
    changeset = Wall.changeset(wall, %{})
    memberships = Memberships.get_members(wall)

    render(conn, "edit.html",
      changeset: changeset,
      wall: wall,
      memberships: memberships
    )
  end

  def update(conn, %{"id" => wall_id, "wall" => %{"name" => name}}, current_user) do
    wall = Walls.get_owned_wall!(current_user, wall_id)

    case Walls.update!(wall, name) do
      {:ok, _wall} ->
        redirect(conn, to: Routes.wall_path(conn, :index))

      {:error, changeset} ->
        memberships = Memberships.get_members(wall)
        render(conn, "edit.html", changeset: changeset, memberships: memberships, wall: wall)
    end
  end

  def delete(conn, %{"id" => wall_id}, current_user) do
    # TODO: Add flash message!
    wall = Walls.get_owned_wall!(current_user, wall_id)
    Walls.delete!(wall)
    redirect(conn, to: Routes.wall_path(conn, :index))
  end

  def revoke_join_link(conn, %{"id" => wall_id}, current_user) do
    wall = Walls.get_owned_wall!(current_user, wall_id)
    |> Join.revoke_token!()
    redirect(conn, to: Routes.wall_path(conn, :edit, wall))
  end
end
