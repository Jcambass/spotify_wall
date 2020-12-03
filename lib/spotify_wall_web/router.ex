defmodule SpotifyWallWeb.Router do
  use SpotifyWallWeb, :router

  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SpotifyWallWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SpotifyWallWeb.Auth
  end

  pipeline :public do
    plug :put_root_layout, {SpotifyWallWeb.LayoutView, :public_root}
    plug SpotifyWallWeb.RedirectSignedIn
  end

  pipeline :admin do
    unless Mix.env() == :dev do
      plug :basic_auth, Application.compile_env(:spotify_wall, :admin_area)
    end
  end

  scope "/auth", SpotifyWallWeb do
    pipe_through :browser

    get "/:provider", AccountConnectionController, :request
    get "/:provider/callback", AccountConnectionController, :callback
    post "/:provider/callback", AccountConnectionController, :callback
  end

  scope "/", SpotifyWallWeb do
    pipe_through [:browser, :public]
    get "/", PublicController, :index
  end

  scope "/", SpotifyWallWeb do
    pipe_through :browser

    get "/invitations/:id", AcceptInvitationController, :show
    # TODO: Ideally we only had `put` and no `get` here.
    put "/invitations/:id/accept", AcceptInvitationController, :accept
    get "/invitations/:id/accept", AcceptInvitationController, :accept
  end

  scope "/", SpotifyWallWeb do
    pipe_through [:browser, :authenticate_user]

    resources "/walls", WallController, except: [:show] do
      delete "/members/:id", MembershipController, :delete
      delete "/invitations/:id", InvitationController, :delete
      post "/invitations", InvitationController, :create
    end

    live "/walls/:id/", WallLive
  end

  scope "/account", SpotifyWallWeb do
    pipe_through [:browser, :authenticate_user]

    get "/", AccountConnectionController, :show
    delete "/", AccountConnectionController, :delete
  end

  scope "/session", SpotifyWallWeb do
    pipe_through [:browser, :authenticate_user]

    delete "/", SessionController, :delete
  end

  scope "/" do
    pipe_through [:browser, :admin]

    live_dashboard "/dashboard",
      metrics: SpotifyWallWeb.Telemetry,
      additional_pages: [
        spotify_sessions: SpotifyWallWeb.LiveDashboard.SpotifySessionsPage
      ],
      ecto_repos: [SpotifyWall.Repo]
  end
end
