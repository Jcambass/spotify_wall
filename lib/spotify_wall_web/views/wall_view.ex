defmodule SpotifyWallWeb.WallView do
  use SpotifyWallWeb, :view

  def is_owner?(wall, user) do
    wall.owner.id == user.id
  end

  def open_revoke_invite_var(invite) do
    "open_revoke_invite_#{invite.id}"
  end

  def init_open_revoke_invite_vars(invites) do
    Enum.map(invites, fn i -> "#{open_revoke_invite_var(i)}: false" end)
    |> Enum.join(", ")
  end
end
