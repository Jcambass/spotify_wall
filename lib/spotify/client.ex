defmodule Spotify.Client do
  @pool_size 10

  def child_spec(_) do
    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Spotify.ClientWorker,
        size: @pool_size
      ],
      []
    )
  end

  def get_activity(token) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid -> Spotify.ClientWorker.get_activity(worker_pid, token) end
    )
  end
end
