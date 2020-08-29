defmodule SpotifyWallWeb.Router do
  use SpotifyWallWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SpotifyWallWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SpotifyWallWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpotifyWallWeb do
    pipe_through :browser

    # TODO: Rename me!
    live "/", PageLive, :index
  end

  scope "/auth", SpotifyWallWeb do
    pipe_through :browser

    get "/:provider", AccountConnectionController, :request
    get "/:provider/callback", AccountConnectionController, :callback
    post "/:provider/callback", AccountConnectionController, :callback
  end

  scope "/account", SpotifyWallWeb do
    pipe_through :browser

    get "/", AccountConnectionController, :show
    delete "/", AccountConnectionController, :delete
  end

  scope "/session", SpotifyWallWeb do
    pipe_through :browser

    delete "/", SessionController, :delete
  end

  # scope "/api", SpotifyWallWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: SpotifyWallWeb.Telemetry
    end
  end
end
