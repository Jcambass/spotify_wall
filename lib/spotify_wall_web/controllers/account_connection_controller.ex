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
              credentials: %{refresh_token: refresh_token, expires_at: expires_at},
              info: %{nickname: nickname}
            }
          }
        } = conn,
        params
      ) do
    # TODO: This is probably quite insecure!
    user = Accounts.upsert_user(nickname, refresh_token, expires_at)

    redirect_url =
      case Map.get(params, "state", nil) do
        nil -> Routes.wall_path(conn, :index)
        "" -> Routes.wall_path(conn, :index)
        encoded_url -> URI.decode(encoded_url)
      end

    conn
    |> SpotifyWallWeb.Auth.login(user)
    |> redirect(to: redirect_url)
  end

  # TODO: Add account deletion feature
end
