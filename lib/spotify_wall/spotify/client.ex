defmodule SpotifyWall.Spotify.Client do
  @moduledoc """
  This module implements a pool of `Spotify.ClientWorker` processes.
  This prevents us from doing to many concurrent requests to Spotify.
  """

  alias SpotifyWall.Spotify.ClientWorker

  @pool_size 10

  def child_spec(_) do
    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: ClientWorker,
        size: @pool_size
      ],
      []
    )
  end

  @doc """
  Checks out a worker and fetches the current activity for a given token.
  """
  def get_activity(token) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid -> ClientWorker.get_activity(worker_pid, token) end
    )
  end

  @doc """
  Checks out a worker and requests a new access token for the given access token.
  """
  def refresh_access_token(refresh_token) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid -> ClientWorker.refresh_access_token(worker_pid, refresh_token) end
    )
  end
end
