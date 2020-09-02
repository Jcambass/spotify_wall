defmodule Spotify.Activities do
  @moduledoc """
  This module providers a simple wrapper around the `Phoenix.PubSub` and can be used to broadcast and subscribe to `activities` updates.
  """

  @doc """
  Subscribes current process to `actitives` updates.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(SpotifyWall.PubSub, "activities")
  end

  @doc """
  Broadcasts the current activity for a given nickname to all subscribed processes.
  """
  def broadcast(nickname, activity) do
    Phoenix.PubSub.broadcast(SpotifyWall.PubSub, "activities", {:activity_updated, nickname, activity})
  end
end
