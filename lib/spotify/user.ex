defmodule Spotify.User do
  use GenServer, restart: :temporary

  @thirty_seconds 30_000
  @five_minutes 300_000

  # TODO: How to refresh token from database?
  def start_link({nickname, token}) do
    GenServer.start_link(Spotify.User, {nickname, token}, name: via_tuple(nickname))
  end

  def get_activity(spotify_user) do
    GenServer.call(spotify_user, :get_activity)
  end

  defp via_tuple(nickname) do
    Spotify.ProcessRegistry.via_tuple({__MODULE__, nickname})
  end

  @impl GenServer
  def init({nickname, token}) do
    IO.puts "Starting Spotify User for #{nickname}"
    schedule_activity_update()
    schedule_token_update()

    {:ok, {nickname, token, Spotify.Client.get_activity(token)}}
  end

  @impl GenServer
  def handle_call(:get_activity, _from, {nickname, token, activity}) do
    {
      :reply,
      activity,
      {nickname, token, activity}
    }
  end

  def handle_info(:update_activity, _from, {nickname, token, _activity}) do
    schedule_activity_update()
    new_activity = Spotify.Client.get_activity(token)
    {:no_reply, {nickname, token, new_activity}}
  end

  def handle_info(:update_token, _from, {nickname, _token, activity}) do
    schedule_token_update()
    # TODO: Find a way without accessing DB? Maybe move token update somehow into here instead with periodic Oban job?
    %{token: new_token} = SpotifyWall.Accounts.get_user_by_nickname!(nickname)
    {:no_reply, {nickname, new_token, activity}}
  end

  defp schedule_activity_update() do
    Process.send_after(self(), :update_activity, @thirty_seconds)
  end

  # TODO: Find a better way without less downtime
  defp schedule_token_update() do
    Process.send_after(self(), :update_token, @five_minutes)
  end
end
