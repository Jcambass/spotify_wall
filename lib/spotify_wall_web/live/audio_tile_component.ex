defmodule SpotifyWallWeb.AudioTileComponent do
  use SpotifyWallWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="user-<%= @id %>" class="user"><%= @user.nickname %></div>
    """
  end
end
