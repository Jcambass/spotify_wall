defmodule SpotifyWall.Spotify.User do
  @moduledoc """
  Represents a Spotify user.
  """

  @enforce_keys [:name, :avatar_url]
  defstruct [:name, :avatar_url]
end
