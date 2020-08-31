defmodule SpotifyWallWeb.PageLive do
  use SpotifyWallWeb, :live_view
  alias SpotifyWall.Accounts

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Spotify.Activities.subscribe()

    users = Accounts.list_users()
    |> Enum.map(fn u -> {u.nickname, get_activity(u)} end)
    |> Enum.filter(fn {_nickname, activity} -> activity end)
    |> Map.new

    {:ok, assign(socket, users: users)}
  end

  @impl true
  def handle_info({:activity_updated, nickname, activity}, socket) do
    fun = if activity do
      fn users -> Map.put(users, nickname, activity) end
    else
      fn users -> Map.delete(users, nickname) end
    end

    {:noreply, update(socket, :users, fun)}
  end

  defp get_activity(user) do
    Spotify.Cache.user_process(user.nickname)
    |> Spotify.User.get_activity()
  end
end
