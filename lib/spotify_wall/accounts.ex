defmodule SpotifyWall.Accounts do
  @moduledoc """
  The Accounts context.
  """

  # 20 minutes
  @refresh_tokens_expiring_in 20 * 60

  import Ecto.Query, warn: false
  alias SpotifyWall.Repo

  alias SpotifyWall.Accounts.User

  require Logger

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_nickname!(nickname), do: Repo.get_by!(User, nickname: nickname)

  def upsert_user(nickname, refresh_token, expires_at) do
    Logger.info("upserted_user", user: %{nickname: nickname})

    attrs = %{
      nickname: nickname,
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

  def list_expiring_users do
    expiration_time = DateTime.add(DateTime.utc_now(), @refresh_tokens_expiring_in)

    Repo.all(
      from u in User,
        where: u.expires_at <= ^expiration_time
    )
  end

  # TODO: allow unconnecting and deleting user.
  def delete_user(%User{} = user) do
    Logger.info("deleted_user", user: %{id: user.id})
    Repo.delete(user)
  end
end
