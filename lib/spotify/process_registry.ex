defmodule Spotify.ProcessRegistry do
  @moduledoc """
  This module provides a node-local process registry that is used to register and retrieve `Spotify.User` processes.
  """

  def start_link do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end
