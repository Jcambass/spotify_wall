defmodule Spotify.Activities do
  @moduledoc """
  This module providers a simple wrapper around the `Phoenix.PubSub` and can be used to broadcast and subscribe to `activities` updates.
  """

  @doc """
  Subscribes current process to `actitives` updates for the given nickname.
  """
  def subscribe_to(nickname) do
    Phoenix.PubSub.subscribe(SpotifyWall.PubSub, "activities:#{nickname}")
  end

  @doc """
  Broadcasts the current activity for a given nickname to all subscribed processes.
  """
  def broadcast(nickname, activity) do
    Phoenix.PubSub.broadcast(
      SpotifyWall.PubSub,
      "activities:#{nickname}",
      {:activity_updated, nickname, activity}
    )
  end
end
