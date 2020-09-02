defmodule Spotify.ClientWorker do
  @moduledoc """
  This module implements a worker process that is ment to be managed by the `Spotify.Worker` pool.
  It serializes interactions with Spotify.
  """
  use GenServer

  def start_link(worker_id) do
    IO.puts("Starting Spotify Client worker #{worker_id}")
    GenServer.start_link(__MODULE__, [])
  end

  @doc """
  Fetches the current listening activity for a given token using the `Spotify.ClientWorker` passed in `pid`.
  """
  def get_activity(pid, token) do
    GenServer.call(pid, {:get_activity, token})
  end

  @impl GenServer
  def init(_arg) do
    {:ok, []}
  end

  @impl GenServer
  def handle_call({:get_activity, token}, _from, state) do
    data = Spotify.API.current_activity(token)

    {:reply, data, state}
  end
end
