defmodule SpotifyWall.Workers.RefreshUserToken do
  use Oban.Worker,
    queue: :cluster,
    unique: [period: :infinity, states: [:available, :scheduled, :executing]]

  alias SpotifyWall.Accounts
  alias Spotify.Client

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id}}) do
    user = Accounts.get_user!(user_id)

    case Client.refresh_access_token(user.refresh_token) do
      {:ok, {token, expires_in}} -> update_token(user, token, expires_in)
      {:error, error} -> handle_error(user, error)
    end

    :ok
  end

  defp update_token(user, token, expires_in) do
    Accounts.update_user_token(user, token, expires_in)
  end

  defp handle_error(user, :refresh_token_revoked) do
    # Remove current activity for user
    # Spotify.Activities.broadcast(user.nickname, nil)
    # TODO: Change user state, stop process and exclude him from the wall.
    nil
  end

  defp handle_error(_user, _error), do: nil
end
