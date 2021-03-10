defmodule SpotifyWallWeb.WallLive do
  use SpotifyWallWeb, :live_view

  alias SpotifyWall.Accounts
  alias SpotifyWall.Accounts.User
  alias SpotifyWall.Memberships
  alias SpotifyWall.Walls
  alias SpotifyWall.Walls.Wall

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

              if is_active_member?(u.nickname, wall_id) do
                active_member_state(u.nickname)
              else
                not_active_member_state(u.nickname)
              end
            catch
              :exit, _ -> fallback_state(u.nickname)
            end

          _ ->
            fallback_state(u.nickname)
        end
      end)

    users =
      users
      |> Enum.filter(fn {_nickname, activity} -> activity end)
      |> Map.new()

    {:ok, assign(socket, users: users, wall_id: wall_id)}
  end

  defp active_member_state(nickname) do
    {Session.full_user_name(nickname), Session.now_playing(nickname)}
  end

  defp not_active_member_state(nickname) do
    {Session.full_user_name(nickname), nil}
  end

  defp fallback_state(nickname) do
    {nickname, nil}
  end

  # Sends `nil` to `now_playing` to trigger an update and check membership of this wall.
  # This relies on the fact that the `handle_info` of `now_playing` checks membership of the current wall so that only the paused/removed memberships get updated.
  def handle_info({:membership_paused, %User{nickname: nickname}}, socket) do
    send(self(), {:now_playing, nickname, nil})
    {:noreply, socket}
  end

  # Sends the current played song to `now_playing` to trigger an update and check membership of this wall.
  # This relies on the fact that the `handle_info` of `now_playing` checks membership of the current wall so that only the paused/removed memberships get updated.
  def handle_info({:membership_resumed, %User{nickname: nickname}}, socket) do
    send(self(), {:now_playing, nickname, Session.now_playing(nickname)})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:now_playing, nickname, activity}, socket) do
    fun =
      if activity && is_active_member?(nickname, socket.assigns[:wall_id]) do
        fn users -> Map.put(users, nickname, activity) end
      else
        fn users -> Map.delete(users, nickname) end
      end

    {:noreply, update(socket, :users, fun)}
  end

  defp is_active_member?(nickname, wall_id) do
    user = Accounts.get_user_by_nickname!(nickname)
    membership = Memberships.get_membership(%Wall{id: wall_id}, user)
    membership && !membership.paused
  end
end
