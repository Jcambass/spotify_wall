defmodule SpotifyWallWeb.AccountConnectionController do
  use SpotifyWallWeb, :controller
  plug Ueberauth

  alias SpotifyWall.Accounts

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(
        %{
          assigns: %{
            ueberauth_auth: %{
              credentials: %{token: token, refresh_token: refresh_token, expires_at: expires_at},
              info: %{nickname: nickname}
            }
          }
        } = conn,
        _params
      ) do
    # TODO: This is probably quite insecure!
    user = Accounts.upsert_user(nickname, token, refresh_token, expires_at)

    conn
    |> put_flash(:info, "Successfully authenticated. #{user.token}")
    |> redirect(to: "/")
  end
end
