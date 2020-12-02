defmodule SpotifyWallWeb.WallLive do
  use SpotifyWallWeb, :live_view

  alias SpotifyWall.Accounts
  alias SpotifyWall.Memberships
  alias SpotifyWall.Walls

  alias SpotifyWall.Spotify.Activities
  alias SpotifyWall.Spotify.Cache
  alias SpotifyWall.Spotify.Session

  @impl true
  def mount(%{"id" => wall_id}, %{"user_id" => user_id} = _session, socket) do
    users =
      Accounts.get_user!(user_id)
      |> Walls.get_wall!(wall_id)
      |> Memberships.get_members()
      |> Enum.map(fn %{user: u} -> {u.nickname, get_activity(u)} end)

    # TODO: Make it clearer that we start a session for each user with get_activity and subscribe each even if we don't find an acitvity for him.
    if connected?(socket) do
      Enum.each(users, fn {nickname, _activity} ->
        Activities.subscribe_to(nickname)
      end)
    end

    users =
      users
      |> Enum.filter(fn {_nickname, activity} -> activity end)
      |> Map.new()

    {:ok, assign(socket, users: users)}
  end

  @impl true
  # TODO: Maybe ensure that user really belongs to the wall.
  def handle_info({:activity_updated, nickname, activity}, socket) do
    fun =
      if activity do
        fn users -> Map.put(users, nickname, activity) end
      else
        fn users -> Map.delete(users, nickname) end
      end

    {:noreply, update(socket, :users, fun)}
  end

  defp get_activity(user) do
    case Cache.session_process(user.nickname) do
      {:ok, pid} -> Session.get_activity(pid)
      {:error, _error} -> nil
    end
  end
end
