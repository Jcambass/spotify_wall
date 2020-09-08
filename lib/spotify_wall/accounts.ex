defmodule SpotifyWall.Accounts do
  @moduledoc """
  The Accounts context.
  """

  # 20 minutes
  @refresh_tokens_expiring_in 20 * 60

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
      expires_at: DateTime.from_unix!(expires_at)
    }

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!(
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: :nickname,
      returning: true
    )
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

  # TODO: allow unconnecting and deleting user.
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end
end
