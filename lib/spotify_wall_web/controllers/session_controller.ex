defmodule SpotifyWallWeb.SessionController do
  use SpotifyWallWeb, :controller

  def delete(conn, _params) do
    conn
    |> SpotifyWallWeb.Auth.logout()
    |> redirect(to: Routes.wall_path(conn, :index))
  end
end
