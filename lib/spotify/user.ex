defmodule Spotify.User do
  use GenServer, restart: :temporary

  @ten_seconds 10_000

  def start_link(nickname) do
    GenServer.start_link(Spotify.User, nickname, name: via_tuple(nickname))
  end

  def get_activity(spotify_user) do
    GenServer.call(spotify_user, :get_activity)
  end

  defp via_tuple(nickname) do
    Spotify.ProcessRegistry.via_tuple({__MODULE__, nickname})
  end

  @impl GenServer
  def init(nickname) do
    IO.puts("Starting Spotify User for #{nickname}")
    schedule_activity_update()

    %{token: token} = SpotifyWall.Accounts.get_user_by_nickname!(nickname)
    {:ok, {nickname, Spotify.Client.get_activity(token)}}
  end

  @impl GenServer
  def handle_call(:get_activity, _from, {nickname, activity}) do
    {
      :reply,
      activity,
      {nickname, activity}
    }
  end

  @impl GenServer
  def handle_info(:update_activity, {nickname, activity}) do
    schedule_activity_update()

    %{token: token} = SpotifyWall.Accounts.get_user_by_nickname!(nickname)
    new_activity = Spotify.Client.get_activity(token)

    if activity != new_activity do
      Spotify.Activities.broadcast(nickname, new_activity)
    end

    {:noreply, {nickname, new_activity}}
  end

  defp schedule_activity_update() do
    Process.send_after(self(), :update_activity, @ten_seconds)
  end
end
