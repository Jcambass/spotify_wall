defmodule SpotifyWall.Workers.RefreshTokens do
  use Oban.Worker, queue: :cluster

  alias SpotifyWall.Accounts

  @impl Oban.Worker
  def perform(_job) do
    Accounts.list_expiring_users()
    |> Enum.each(fn u ->
      %{user_id: u.id}
      |> SpotifyWall.Workers.RefreshUserToken.new()
      |> Oban.insert()
    end)

    :ok
  end
end
