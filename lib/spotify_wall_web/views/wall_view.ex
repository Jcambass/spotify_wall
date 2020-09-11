defmodule SpotifyWallWeb.WallView do
  use SpotifyWallWeb, :view
  alias SpotifyWall.Invitations.Invitation
  alias SpotifyWall.Memberships.Membership

  def is_owner?(wall, user) do
    wall.owner.id == user.id
  end

  def open_modal_var(struct) do
    case struct do
      %Invitation{id: id} -> "open_revoke_invite_#{id}"
      %Membership{id: id} -> "open_remove_member_#{id}"
    end
  end

  def init_open_modal_vars(structs) do
    Enum.map(structs, fn struct -> "#{open_modal_var(struct)}: false" end)
    |> Enum.join(", ")
  end
end
