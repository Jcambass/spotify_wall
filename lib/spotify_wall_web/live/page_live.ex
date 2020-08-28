defmodule SpotifyWallWeb.PageLive do
  use SpotifyWallWeb, :live_view
  alias SpotifyWall.Accounts

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users()
    {:ok, assign(socket, users: users)}
  end
end
