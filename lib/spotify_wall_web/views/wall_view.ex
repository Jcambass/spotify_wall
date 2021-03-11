defmodule SpotifyWallWeb.WallView do
  use SpotifyWallWeb, :view
  alias SpotifyWall.Memberships.Membership
  alias SpotifyWall.Walls.Wall

  def is_owner?(wall, user) do
    wall.owner.id == user.id
  end

  def open_modal_var(struct) do
    case struct do
      %Membership{id: id} -> "open_remove_member_#{id}"
      %Wall{id: id} -> "open_leave_wall_#{id}"
    end
  end

  def init_open_modal_vars(structs) do
    Enum.map(structs, fn struct -> "#{open_modal_var(struct)}: false" end)
    |> Enum.join(", ")
  end

  def pause_resume_button(conn, membership) do
    if membership.paused do
      ~e"""
        <%= link(to: Routes.wall_membership_path(conn, :resume, membership.wall.id), method: :put, class: "relative w-0 flex-1 inline-flex items-center justify-center py-4 text-sm leading-5 text-gray-700 font-medium border border-transparent rounded-br-lg hover:text-gray-500 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 focus:z-10 transition ease-in-out duration-150") do %>
          <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
          <span class="ml-3">Start Sharing</span>
        <% end %>
      """
    else
      ~e"""
        <%= link(to: Routes.wall_membership_path(conn, :pause, membership.wall.id), method: :put, class: "relative w-0 flex-1 inline-flex items-center justify-center py-4 text-sm leading-5 text-gray-700 font-medium border border-transparent rounded-br-lg hover:text-gray-500 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 focus:z-10 transition ease-in-out duration-150") do %>
          <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
          <span class="ml-3">Stop Sharing</span>
        <% end %>
      """
    end
  end

  def view_button(conn, wall) do
    ~e"""
      <%= link(to: Routes.live_path(conn, SpotifyWallWeb.WallLive, wall.id), class: "relative -mr-px w-0 flex-1 inline-flex items-center justify-center py-4 text-sm leading-5 text-gray-700 font-medium border border-transparent rounded-bl-lg hover:text-gray-500 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 focus:z-10 transition ease-in-out duration-150") do %>
        <svg class="w-5 h-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor">
          <path d="M11 3a1 1 0 100 2h2.586l-6.293 6.293a1 1 0 101.414 1.414L15 6.414V9a1 1 0 102 0V4a1 1 0 00-1-1h-5z" />
          <path d="M5 5a2 2 0 00-2 2v8a2 2 0 002 2h8a2 2 0 002-2v-3a1 1 0 10-2 0v3H5V7h3a1 1 0 000-2H5z" />
        </svg>
        <span class="ml-3">View</span>
        <% end %>
      </a>
    """
  end

  def manage_button(conn, wall) do
    ~e"""
      <%= link(to: Routes.wall_path(conn, :edit, wall.id), class: "relative w-0 flex-1 inline-flex items-center justify-center py-4 text-sm leading-5 text-gray-700 font-medium border border-transparent rounded-br-lg hover:text-gray-500 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 focus:z-10 transition ease-in-out duration-150") do %>
        <svg class="w-5 h-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M11.49 3.17c-.38-1.56-2.6-1.56-2.98 0a1.532 1.532 0 01-2.286.948c-1.372-.836-2.942.734-2.106 2.106.54.886.061 2.042-.947 2.287-1.561.379-1.561 2.6 0 2.978a1.532 1.532 0 01.947 2.287c-.836 1.372.734 2.942 2.106 2.106a1.532 1.532 0 012.287.947c.379 1.561 2.6 1.561 2.978 0a1.533 1.533 0 012.287-.947c1.372.836 2.942-.734 2.106-2.106a1.533 1.533 0 01.947-2.287c1.561-.379 1.561-2.6 0-2.978a1.532 1.532 0 01-.947-2.287c.836-1.372-.734-2.942-2.106-2.106a1.532 1.532 0 01-2.287-.947zM10 13a3 3 0 100-6 3 3 0 000 6z" clip-rule="evenodd" />
        </svg>
        <span class="ml-3">Manage</span>
      <% end %>
    """
  end

  def leave_button(wall) do
    ~e"""
      <a @click="<%= open_modal_var(wall) %> = true" href="#" class="relative w-0 flex-1 inline-flex items-center justify-center py-4 text-sm leading-5 text-gray-700 font-medium border border-transparent rounded-br-lg hover:text-gray-500 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 focus:z-10 transition ease-in-out duration-150">
        <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7a4 4 0 11-8 0 4 4 0 018 0zM9 14a6 6 0 00-6 6v1h12v-1a6 6 0 00-6-6zM21 12h-6"></path></svg>
        <span class="ml-3">Leave</span>
      </a>
    """
  end

  def wall_actions(conn, membership, current_user) do
    ~e"""
      <div class="-mt-px flex">
        <%= if is_owner?(membership.wall, current_user) do %>
          <div class="w-0 flex-1 flex border-r border-gray-200">
            <%= view_button(conn, membership.wall) %>
          </div>
          <div class="-ml-px w-0 flex-1 flex border-r border-gray-200">
            <%= pause_resume_button(conn, membership) %>
          </div>
          <div class="-ml-px w-0 flex-1 flex">
            <%= manage_button(conn, membership.wall) %>
          </div>
        <% else %>
          <div class="w-0 flex-1 flex border-gray-200">
            <%= view_button(conn, membership.wall) %>
          </div>
          <div class="-ml-px w-0 flex-1 flex">
            <%= pause_resume_button(conn, membership) %>
          </div>
          <div class="-ml-px w-0 flex-1 flex">
            <%= leave_button(membership.wall) %>
          </div>
        <% end %>
      </div>
    """
  end
end
