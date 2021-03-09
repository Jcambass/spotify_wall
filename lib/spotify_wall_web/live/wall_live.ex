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
        # TODO: sending a message to a dead proccess
        # figure out how the error reporting works
        # Maybe add separate state for revoked tokens instead of shutting the process down
        # Alternatively somehow handle the dead process
        case Session.setup(u.nickname, Credentials.from_user(u)) do
          # TODO: Solve this problem in another more sane way.
          :ok ->
            try do
              if connected?(socket) do
                Session.subscribe(u.nickname)
              end

              {Session.full_user_name(u.nickname), Session.now_playing(u.nickname)}
            catch
              :exit, _ -> {u.nickname, nil}
            end

          _ ->
            {u.nickname, nil}
        end
      end)

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
