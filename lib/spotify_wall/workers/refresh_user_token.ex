defmodule SpotifyWall.Workers.RefreshUserToken do
  use Oban.Worker,
    queue: :cluster,
    unique: [period: :infinity, states: [:available, :scheduled, :executing]]

  alias SpotifyWall.Accounts
  alias SpotifyWall.Spotify

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{user_id: user_id}}) do
    user = Accounts.get_user!(user_id)
    {token, expires_in} = Spotify.refresh_access_token(user.refresh_token)
    Accounts.update_user_token(user, token, expires_in)

    :ok
  end
end
