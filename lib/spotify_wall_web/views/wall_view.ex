defmodule SpotifyWallWeb.WallView do
  use SpotifyWallWeb, :view

  def is_owner?(wall, user) do
    wall.owner.id == user.id
  end
end
