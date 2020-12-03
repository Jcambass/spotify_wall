defmodule SpotifyWall.Spotify.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {Registry, keys: :unique, name: SpotifyWall.Spotify.SessionRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: SpotifyWall.Spotify.SessionSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def ensure_session(id, credentials) do
    case start_session(id, credentials) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
      {:error, error} -> error
    end
  end

  defp start_session(id, credentials) do
    DynamicSupervisor.start_child(
      SpotifyWall.Spotify.SessionSupervisor,
      {SpotifyWall.Spotify.Session, {id, credentials}}
    )
  end

  def count_sessions do
    count = DynamicSupervisor.count_children(SpotifyWall.Spotify.SessionSupervisor)
    :telemetry.execute([:spotify_wall, :session, :count], count)
  end

  def sessions do
    SpotifyWall.Spotify.SessionRegistry
    |> Registry.select([{{:"$1", :"$2", :_}, [], [{{:"$1", :"$2"}}]}])
    |> Enum.map(fn {id, pid} ->
      subscribers_count = SpotifyWall.Spotify.Session.subscribers_count(id)
      %{id: id, pid: pid, clients_count: subscribers_count}
    end)
  end
end
