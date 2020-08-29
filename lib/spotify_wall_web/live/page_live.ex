defmodule SpotifyWallWeb.PageLive do
  use SpotifyWallWeb, :live_view
  alias SpotifyWall.Accounts

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users()
    |> Enum.map(fn u -> {u, get_activity(u)} end)
    |> Enum.filter(fn {_u, activity} -> activity end)

    {:ok, assign(socket, users: users)}
  end

  # TODO: Move to me liveview and make live updates periodic or based on state update.
  defp get_activity(user) do
    Spotify.Cache.user_process(user.nickname)
    |> Spotify.User.get_activity()
  end
end
