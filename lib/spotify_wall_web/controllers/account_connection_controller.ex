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
              credentials: %{refresh_token: refresh_token},
              info: %{nickname: nickname}
            }
          }
        } = conn,
        params
      ) do
    # TODO: Explore using state to prevent CSSRF and store redirection url in cookie.

    # TODO: This is not great since attackers could just put their refresh_token and another users nickname.
    # This would cause the attacks activity to show up under the name and in the walls of the other user.
    user = Accounts.upsert_user(nickname, refresh_token)

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
