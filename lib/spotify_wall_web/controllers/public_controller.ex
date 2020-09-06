defmodule SpotifyWallWeb.PublicController do
  use SpotifyWallWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
