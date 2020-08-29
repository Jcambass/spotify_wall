defmodule Spotify.Cache do
  def start_link() do
    IO.puts("Starting Spotify Cache.")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def user_process(nickname) do
    case start_child(nickname) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(nickname) do
    DynamicSupervisor.start_child(__MODULE__, {Spotify.User, nickname})
  end
end
