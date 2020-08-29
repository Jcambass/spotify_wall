defmodule SpotifyWallWeb.SessionController do
  use SpotifyWallWeb, :controller

  def delete(conn, _params) do
    conn
    |> SpotifyWallWeb.Auth.logout()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
