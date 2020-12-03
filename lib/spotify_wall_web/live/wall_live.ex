defmodule SpotifyWallWeb.WallLive do
  use SpotifyWallWeb, :live_view

  alias SpotifyWall.Accounts
  alias SpotifyWall.Memberships
  alias SpotifyWall.Walls

  alias SpotifyWall.Spotify.{Session, Credentials}

  @impl true
  def mount(%{"id" => wall_id}, %{"user_id" => user_id} = _session, socket) do
    users =
      Accounts.get_user!(user_id)
      |> Walls.get_wall!(wall_id)
      |> Memberships.get_members()
      |> Enum.map(fn %{user: u} ->
        Session.setup(u.nickname, Credentials.from_user(u))
        {u.nickname, Session.now_playing(u.nickname)}
      end)

    if connected?(socket) do
      Enum.each(users, fn {nickname, _activity} ->
        Session.subscribe(nickname)
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
  def handle_info({:now_playing, nickname, activity}, socket) do
    fun =
      if activity do
        fn users -> Map.put(users, nickname, activity) end
      else
        fn users -> Map.delete(users, nickname) end
      end

    {:noreply, update(socket, :users, fun)}
  end
end
