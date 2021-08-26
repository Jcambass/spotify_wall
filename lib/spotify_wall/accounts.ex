defmodule SpotifyWall.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias SpotifyWall.Repo

  alias SpotifyWall.Accounts.User

  require Logger

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_nickname!(nickname), do: Repo.get_by!(User, nickname: nickname)

  def upsert_user(nickname, refresh_token) do
    Logger.info("upserted_user", user: %{nickname: nickname})

    attrs = %{
      nickname: nickname,
      refresh_token: refresh_token
    }

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!(
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: :nickname,
      returning: true
    )
  end

  # TODO: allow unconnecting and deleting user.
  def delete_user(%User{} = user) do
    Logger.info("deleted_user", user: %{id: user.id})
    Repo.delete(user)
  end
end
