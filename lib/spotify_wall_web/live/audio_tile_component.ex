defmodule SpotifyWallWeb.AudioTileComponent do
  use SpotifyWallWeb, :live_component

  def render(assigns) do
    ~L"""
      <li id="user-<%= @id %>" class="py-10 px-6 bg-gray-800 text-center rounded-lg xl:px-10 xl:text-left">
        <div class="space-y-6 xl:space-y-10">
          <p class="font-medium text-lg text-indigo-200 text-center"><%= @nickname %> listens to</p>
          <img class="mx-auto h-40 w-40 rounded-lg xl:w-56 xl:h-56" src="<%= @activity.image %>" alt="">
          <div class="space-y-2 xl:flex xl:items-center xl:justify-between">
            <div class="font-medium text-lg leading-6 space-y-1">
              <a href="<%= @activity.url %>">
                <p class="text-indigo-400"><%= @activity.track %></p>
              </a>
              <h4 class="text-white"><%= @activity.artists %></h4>
            </div>
          </div>
        </div>
      </li>
    """
  end
end
