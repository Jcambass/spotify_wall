defmodule Spotify.API do
  use Tesla

  plug Tesla.Middleware.DecodeJson
  plug Tesla.Middleware.FormUrlencoded
  plug Tesla.Middleware.Telemetry

  alias Spotify.Activity

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

  # TODO: Handle rate limiting
  def current_activity(token) do
    {:ok, %{body: body}} =
      get("https://api.spotify.com/v1/me/player/currently-playing",
        headers: [{"Authorization", "Bearer #{token}"}]
      )

    case body do
      %{"item" => item} -> parse_item(item)
      _body -> nil
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
    image = Map.get(List.first(images), "url")

    artists =
      artists
      |> Enum.map(fn a -> Map.get(a, "name") end)
      |> Enum.join(", ")

    %Activity{
      track: track_name,
      album: album_name,
      image: image,
      artists: artists,
      url: spotify_url,
      preview: preview_url
    }
  end

  defp parse_item(_item), do: nil
end
