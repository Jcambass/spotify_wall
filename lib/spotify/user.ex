defmodule Spotify.User do
  use GenServer, restart: :temporary

  @ten_seconds 10_000

  def start_link(nickname) do
    GenServer.start_link(Spotify.User, nickname, name: via_tuple(nickname))
  end

  def get_activity(spotify_user) do
    try do
      GenServer.call(spotify_user, :get_activity)
    catch
      :exit, _reason -> nil
    end
  end

  defp via_tuple(nickname) do
    Spotify.ProcessRegistry.via_tuple({__MODULE__, nickname})
  end

  @impl GenServer
  def init(nickname) do
    IO.puts("Starting Spotify User for #{nickname}")
    {:ok, {nickname, nil}, {:continue, :init_activity}}
  end

  @impl GenServer
  def handle_continue(:init_activity, {nickname, nil}) do
    schedule_activity_update()
    new_activity = fetch_activity(nickname)
    maybe_broadcast(nickname, nil, new_activity)

    {:noreply, {nickname, new_activity}}
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
    new_activity = fetch_activity(nickname)
    maybe_broadcast(nickname, activity, new_activity)

    {:noreply, {nickname, new_activity}}
  end

  @impl GenServer
  def terminate(reason, {nickname, activity}) do
    IO.puts("Spotify User #{nickname} terminated. Reason: #{Kernel.inspect(reason)}")
    maybe_broadcast(nickname, activity, nil)
  end

  defp fetch_activity(nickname) do
    %{token: token} = SpotifyWall.Accounts.get_user_by_nickname!(nickname)
    Spotify.Client.get_activity(token)
  end

  defp maybe_broadcast(nickname, activity, new_activity) do
    if activity != new_activity do
      Spotify.Activities.broadcast(nickname, new_activity)
    end
  end

  defp schedule_activity_update() do
    Process.send_after(self(), :update_activity, @ten_seconds)
  end
end
