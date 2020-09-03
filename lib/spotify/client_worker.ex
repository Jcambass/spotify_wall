defmodule Spotify.ClientWorker do
  @moduledoc """
  This module implements a worker process that is ment to be managed by the `Spotify.Worker` pool.
  It serializes interactions with Spotify.
  """
  use GenServer

  def start_link(_args) do
    IO.puts("Starting Spotify Client worker.")
    GenServer.start_link(__MODULE__, [])
  end

  @doc """
  Fetches the current listening activity for a given token using the `Spotify.ClientWorker` passed in `pid`.
  """
  def get_activity(pid, token) do
    GenServer.call(pid, {:get_activity, token})
  end

  @doc """
  Fetches a new access token and it's ttl for a given refresh token.
  """
  def refresh_access_token(pid, refresh_token) do
    GenServer.call(pid, {:refresh_access_token, refresh_token})
  end

  @impl GenServer
  def init(_arg) do
    {:ok, []}
  end

  @impl GenServer
  def handle_call({:get_activity, token}, _from, state) do
    res = Spotify.API.current_activity(token)

    {:reply, res, state}
  end

  @impl GenServer
  def handle_call({:refresh_access_token, refresh_token}, _from, state) do
    res = Spotify.API.refresh_access_token(refresh_token)

    {:reply, res, state}
  end
end
