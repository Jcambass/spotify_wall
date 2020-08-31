defmodule Spotify.Activities do
  def subscribe do
    Phoenix.PubSub.subscribe(SpotifyWall.PubSub, "activities")
  end

  def broadcast(nickname, activity) do
    Phoenix.PubSub.broadcast(SpotifyWall.PubSub, "activities", {:activity_updated, nickname, activity})
  end
end
