defmodule Spotify.User do
  @moduledoc """
  This module implements a user process that holds the currently playing track for a nickname.
  The current activity is fetched when creating the process and is periodically updated every 10 seconds.
  The cached activity can be retrieved from the process anytime.
  """

  use GenServer, restart: :temporary
  require Logger

  @ten_seconds 10_000

  def start_link(nickname) do
    GenServer.start_link(Spotify.User, nickname, name: via_tuple(nickname))
  end

  @doc """
  Retrieves the stored current activity from the `Spotify.User` process `spotify_user`.
  Returns `nil` as the activity if the user process has crashed.
  """
  def get_activity(spotify_user) do
    GenServer.call(spotify_user, :get_activity)
  end

  defp via_tuple(nickname) do
    Spotify.ProcessRegistry.via_tuple({__MODULE__, nickname})
  end

  @impl GenServer
  def init(nickname) do
    Logger.info("Starting Spotify User for #{nickname}")

    # TODO: Move me to `handle_continue` without the need to catch exits in two places!
    schedule_activity_update()
    new_activity = fetch_activity(nickname)
    maybe_broadcast(nickname, nil, new_activity)

    {:ok, {nickname, new_activity}}
  end

  @impl GenServer
  def handle_call(:get_activity, _from, {nickname, activity}) do
    {
      :reply,
      activity,
      {nickname, activity}
    }
  end

  # Periodically update the users activity.
  @impl GenServer
  def handle_info(:update_activity, {nickname, activity}) do
    schedule_activity_update()
    new_activity = fetch_activity(nickname)
    maybe_broadcast(nickname, activity, new_activity)

    {:noreply, {nickname, new_activity}}
  end

  @impl GenServer
  # Broadcast activity as `nil` if the user process is about to die.
  def terminate(reason, {nickname, activity}) do
    Logger.info("Spotify User #{nickname} terminated. Reason: #{Kernel.inspect(reason)}")
    maybe_broadcast(nickname, activity, nil)
  end

  # TODO: Store token and automically renew it when it fails.
  # TODO: Remove Oban.
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
