defmodule Spotify.API do
  use Tesla

  plug Tesla.Middleware.DecodeJson
  plug Tesla.Middleware.FormUrlencoded

  def refresh_access_token(refresh_token) do
    auth = build_auth()

    {:ok, %{body: body}} =
      post(
        "https://accounts.spotify.com/api/token",
        %{grant_type: "refresh_token", refresh_token: refresh_token},
        headers: [{"Authorization", "Basic #{auth}"}]
      )

      %{"access_token" => token, "expires_in" => expires_in} = body

      {token, expires_in}
  end

  def current_activity(token) do
    {:ok, %{body: body}} =
      get("https://api.spotify.com/v1/me/player/currently-playing",
        headers: [{"Authorization", "Bearer #{token}"}]
      )

    case body do
      "" -> nil
      %{"item" => item} -> parse_item(item)
    end
  end

  defp build_auth() do
    credentials = Application.get_env(:ueberauth, Ueberauth.Strategy.Spotify.OAuth)
    client_id = Keyword.get(credentials, :client_id)
    client_secret = Keyword.get(credentials, :client_secret)
    Base.encode64("#{client_id}:#{client_secret}")
  end

  defp parse_item(%{
         "album" => %{"name" => album_name, "images" => images},
         "artists" => artists,
         "preview_url" => preview_url,
         "name" => track_name,
         "external_urls" => %{"spotify" => spotify_url}
       }) do
    track_name
  end
end
