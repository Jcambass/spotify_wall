defmodule SpotifyWall.Spotify.Client do
  @moduledoc """
  This module implements an API Client for the Spotify API.
  """

  use Tesla

  plug Tesla.Middleware.DecodeJson
  plug Tesla.Middleware.FormUrlencoded
  plug Tesla.Middleware.Telemetry

  alias SpotifyWall.Spotify.{Activity, User, Credentials}

  require Logger

  def get_token(refresh_token) do
    auth = build_auth()

    case post(
           "https://accounts.spotify.com/api/token",
           %{grant_type: "refresh_token", refresh_token: refresh_token},
           headers: [{"Authorization", "Basic #{auth}"}]
         ) do
      {:ok, %{status: 200} = response} ->
        track_success(:get_token)

        auth_data =
          response.body
          |> parse_auth_data(refresh_token)

        {:ok, auth_data}

      other_response ->
        handle_errors(other_response, :get_token)
    end
  end

  def get_profile(token) do
    case get("https://api.spotify.com/v1/me",
           headers: [{"Authorization", "Bearer #{token}"}]
         ) do
      {:ok, %{status: 200} = response} ->
        track_success(:get_profile)

        user =
          response.body
          |> parse_profile()

        {:ok, user}

      other_response ->
        handle_errors(other_response, :get_profile)
    end
  end

  # TODO: Handle rate limiting
  def now_playing(token) do
    case get("https://api.spotify.com/v1/me/player/currently-playing",
           headers: [{"Authorization", "Bearer #{token}"}]
         ) do
      {:ok, %{status: 204}} ->
        {:ok, nil}

      {:ok, %{status: 200} = response} ->
        track_success(:now_playing)

        activity =
          response.body
          |> parse_now_playing()

        {:ok, activity}

      other_response ->
        handle_errors(other_response, :now_playing)
    end
  end

  defp build_auth() do
    credentials = Application.get_env(:ueberauth, Ueberauth.Strategy.Spotify.OAuth)
    client_id = Keyword.get(credentials, :client_id)
    client_secret = Keyword.get(credentials, :client_secret)
    Base.encode64("#{client_id}:#{client_secret}")
  end

  defp parse_now_playing(%{
         "item" => %{
           "album" => %{"name" => album_name, "images" => images},
           "artists" => artists,
           "preview_url" => preview_url,
           "name" => track_name,
           "external_urls" => %{"spotify" => spotify_url}
         }
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

  defp parse_auth_data(data, refresh_token) do
    %Credentials{
      refresh_token: refresh_token,
      token: data["access_token"]
    }
  end

  defp parse_profile(data) do
    %User{
      name: Map.get(data, "display_name"),
      avatar_url: get_in(data, ["images", Access.at(0), "url"])
    }
  end

  defp handle_errors(response, endpoint) do
    case response do
      {:ok, %{status: 401 = status, body: body}} ->
        if %{"error" => %{"message" => "The access token expired"}} = body do
          track_error(:expired_token, status, endpoint)
          {:error, :expired_token}
        else
          track_error(:invalid_token, status, endpoint)
          {:error, :invalid_token}
        end

      {:ok, %{status: status, body: body}} ->
        track_error(:error_response, status, body, endpoint)
        {:error, status}

      {:error, reason} = error ->
        track_connection_error(reason, endpoint)
        error
    end
  end

  defp track_success(endpoint) do
    Logger.info(fn ->
      "Spotify HTTP Api request: #{endpoint}"
    end)
  end

  defp track_error(type, status, endpoint) do
    Logger.warn(fn ->
      "Spotify HTTP Api error: #{type} on #{endpoint}"
    end)

    :telemetry.execute([:spotify_wall, :spotify, :api_error], %{count: 1}, %{
      error_type: type,
      status: status
    })
  end

  defp track_error(type, status, body, endpoint) do
    Logger.warn(fn ->
      "Spotify HTTP Api error: #{status}, #{inspect_body(body)} on #{endpoint}"
    end)

    :telemetry.execute([:spotify_wall, :spotify, :api_error], %{count: 1}, %{
      error_type: type,
      status: status
    })
  end

  defp track_connection_error(reason, endpoint) do
    Logger.warn(fn ->
      "Spotify HTTP Api connection error: #{reason} on #{endpoint}"
    end)

    :telemetry.execute([:spotify_wall, :spotify, :api_error], %{count: 1}, %{
      error_type: :connection_error
    })
  end

  defp inspect_body(body) when is_map(body) do
    Jason.encode!(body)
  end

  defp inspect_body(body) when is_binary(body) do
    body
  end
end
