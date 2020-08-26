defmodule SpotifyWallWeb.AccountConnectionController do
  use SpotifyWallWeb, :controller
  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    # TODO: Use nickname as uid
    conn
    |> put_flash(:info, "Successfully authenticated. #{auth.credentials.token}")
    |> redirect(to: "/")
  end
end
