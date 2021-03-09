defmodule SpotifyWallWeb.WallView do
  use SpotifyWallWeb, :view
  alias SpotifyWall.Memberships.Membership

  def is_owner?(wall, user) do
    wall.owner.id == user.id
  end

  def open_modal_var(%Membership{id: id}) do
    "open_remove_member_#{id}"
  end

  def init_open_modal_vars(structs) do
    Enum.map(structs, fn struct -> "#{open_modal_var(struct)}: false" end)
    |> Enum.join(", ")
  end
end
