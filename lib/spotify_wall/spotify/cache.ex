defmodule SpotifyWall.Spotify.Cache do
  @moduledoc """
  This module provides a Cache of Spotify.Session processes.
  Using `session_process` a Spotify.Session process for a given nickname can be created/retrieved.
  Each session process is supervised.
  """

  require Logger

  @doc """
  Starts dynamic supervisor for all `Spotify.Session` processes.
  """
  def start_link() do
    Logger.info("Starting Spotify Cache.")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  @doc """
  Creates or Retrieves an `Spotify.Session` process for the given nickname and returns its pid as `{:ok, pid}`.
  If the session process fails to initialize (exceptions raised or exited) an error tuple like `{:error, error}` will be returned.
  """
  def session_process(nickname) do
    case start_child(nickname) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, error} -> {:error, error}
    end
  end

  def sessions do
    SpotifyWall.Spotify.SessionRegistry
    |> Registry.select([{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}])
    |> Enum.map(fn {id, pid} ->
      %{id: id, pid: pid}
    end)
  end

  defp start_child(nickname) do
    DynamicSupervisor.start_child(__MODULE__, {SpotifyWall.Spotify.Session, nickname})
  end
end
