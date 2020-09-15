defmodule Spotify.User do
  @moduledoc """
  This module implements a user process that holds the currently playing track for a nickname.
  The current activity is fetched when creating the process and is periodically updated every 10 seconds.
  The cached activity can be retrieved from the process anytime.
  """

  use GenServer, restart: :temporary
  require Logger

  @ten_seconds 10_000

  # TODO: Maybe Terminate user process after 30 minutes of inactivity (no activity reqyested)

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

  def update_token(spotify_user, token) do
    GenServer.cast(spotify_user, {:update_token, token})
  end

  defp via_tuple(nickname) do
    Spotify.ProcessRegistry.via_tuple({__MODULE__, nickname})
  end

  @impl GenServer
  def init(nickname) do
    Logger.info("Starting Spotify User for #{nickname}")

    # TODO: Move me to `handle_continue` without the need to catch exits in two places!
    schedule_activity_update()
    %{token: token} = SpotifyWall.Accounts.get_user_by_nickname!(nickname)
    new_activity = fetch_activity(token)
    maybe_broadcast(nickname, nil, new_activity)

    {:ok, {nickname, token, new_activity}}
  end

  @impl GenServer
  def handle_call(:get_activity, _from, {nickname, token, activity}) do
    {
      :reply,
      activity,
      {nickname, token, activity}
    }
  end

  # TODO: Store token and automically renew it when it fails.
  # TODO: Remove Oban.
  @impl GenServer
  def handle_cast({:update_token, new_token}, {nickname, _token, activity}) do
    Logger.info("Token for Spotify User #{nickname} updated.")
    {
      :noreply,
      {nickname, new_token, activity}
    }
  end

  # Periodically update the users activity.
  @impl GenServer
  def handle_info(:update_activity, {nickname, token, activity}) do
    schedule_activity_update()
    new_activity = fetch_activity(token)
    maybe_broadcast(nickname, activity, new_activity)

    {:noreply, {nickname, token, new_activity}}
  end

  @impl GenServer
  # Broadcast activity as `nil` if the user process is about to die.
  def terminate(reason, {nickname, _token, activity}) do
    Logger.info("Spotify User #{nickname} terminated. Reason: #{Kernel.inspect(reason)}")
    maybe_broadcast(nickname, activity, nil)
  end

  defp fetch_activity(token) do
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
