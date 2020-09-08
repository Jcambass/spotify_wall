defmodule SpotifyWallWeb.RedirectSignedIn do
  import Plug.Conn
  import Phoenix.Controller
  alias SpotifyWallWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns.current_user do
      conn
      |> redirect(to: Routes.wall_path(conn, :index))
      |> halt()
    else
      conn
    end
  end
end
