defmodule SpotifyWall.Accounts do
  @moduledoc """
  The Accounts context.
  """

  # 10 minutes
  @refresh_tokens_expiring_in 10 * 60

  import Ecto.Query, warn: false
  alias SpotifyWall.Repo

  alias SpotifyWall.Accounts.User

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_nickname!(nickname), do: Repo.get_by!(User, nickname: nickname)

  def upsert_user(nickname, token, refresh_token, expires_at) do
    attrs = %{
      nickname: nickname,
      token: token,
      refresh_token: refresh_token,
      expires_at: expires_at
    }

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

  def update_user_token(user, token, expires_in) do
    expires_at = DateTime.add(DateTime.truncate(DateTime.utc_now(), :second), expires_in)
    User.changeset(user, %{token: token, expires_at: expires_at})
    |> Repo.update!()
  end

  def list_expiring_users do
    expiration_time = DateTime.add(DateTime.utc_now(), @refresh_tokens_expiring_in)

    Repo.all(
      from u in User,
        where: u.expires_at <= ^expiration_time
    )
  end

  # TODO: Perform periodic user cleanup
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end
end
