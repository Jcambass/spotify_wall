defmodule SpotifyWall.Spotify do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.spotify.com/v1"
  plug Tesla.Middleware.DecodeJson
  plug Tesla.Middleware.FormUrlencoded

  def current_activity(token) do
    {:ok, %{body: body}} = get("/me/player/currently-playing", headers: [{"Authorization", "Bearer #{token}"}])

    case body do
      "" -> nil
      %{"item" => item} -> parse_item(item)
    end
  end

  defp parse_item(%{"album" => %{ "name" => album_name, "images" => images}, "artists" => artists, "preview_url" => preview_url, "name" => track_name, "external_urls" => %{"spotify" => spotify_url}}) do
    track_name
  end
end
