defmodule SpotifyWall.Spotify.Session do
  @moduledoc """
  This module implements a session process that holds the currently playing track for a nickname.
  The current activity is fetched when creating the process and is periodically updated every 10 seconds.
  The cached activity can be retrieved from the process anytime.
  """

  alias SpotifyWall.Spotify.SessionRegistry
  alias SpotifyWall.Spotify.Client
  alias SpotifyWall.Spotify.Activities

  use GenServer, restart: :temporary
  require Logger

  @ten_seconds 10_000

  # TODO: Maybe Terminate user process after 30 minutes of inactivity (no activity reqyested)

  def start_link(nickname) do
    GenServer.start_link(__MODULE__, nickname, name: via_tuple(nickname))
  end

  @doc """
  Retrieves the stored current activity from the `Spotify.Session` process `session`.
  Returns `nil` as the activity if the user process has crashed.
  """
  def get_activity(session) do
    GenServer.call(session, :get_activity)
  end

  def update_token(session, token) do
    GenServer.cast(session, {:update_token, token})
  end

  defp via_tuple(nickname) do
    SessionRegistry.via_tuple(nickname)
  end

  @impl GenServer
  def init(nickname) do
    Logger.info("Starting Spotify Session for #{nickname}")

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
    Logger.info("Token for Spotify Session #{nickname} updated.")
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
    Logger.info("Spotify Session #{nickname} terminated. Reason: #{Kernel.inspect(reason)}")
    maybe_broadcast(nickname, activity, nil)
  end

  defp fetch_activity(token) do
    Client.get_activity(token)
  end

  defp maybe_broadcast(nickname, activity, new_activity) do
    if activity != new_activity do
      Activities.broadcast(nickname, new_activity)
    end
  end

  defp schedule_activity_update() do
    Process.send_after(self(), :update_activity, @ten_seconds)
  end
end
