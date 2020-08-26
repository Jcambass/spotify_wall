defmodule SpotifyWall.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias SpotifyWall.Repo

  alias SpotifyWall.Accounts.User

  def upsert_user(nickname, token, refresh_token, expires_at) do
    attrs = %{nickname: nickname, token: token, refresh_token: refresh_token, expires_at: expires_at}

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!(
    on_conflict: :replace_all,
    conflict_target: :nickname,
    returning: true
    )
  end

  def list_users do
    Repo.all(User)
  end

  # TODO: Perform periodic user cleanup
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end
end
