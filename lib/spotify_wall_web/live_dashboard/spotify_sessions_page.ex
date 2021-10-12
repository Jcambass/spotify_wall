defmodule SpotifyWallWeb.LiveDashboard.SpotifySessionsPage do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder

  @impl true
  def menu_link(_, _) do
    {:ok, "Spotify Sessions"}
  end

  @impl true
  def render_page(_assigns) do
    table(
      columns: columns(),
      id: :spotify_sessions,
      row_attrs: &row_attrs/1,
      row_fetcher: &fetch_sessions/2,
      rows_name: "sessions",
      title: "Spotify Sessions"
    )
  end

  defp fetch_sessions(_params, _node) do
    sessions = SpotifyWall.Spotify.Supervisor.sessions()

    {sessions, length(sessions)}
  end

  defp columns do
    [
      %{field: :id, header: "Session ID"},
      %{
        field: :pid,
        header: "Worker PID",
        format: &(&1 |> encode_pid() |> String.replace_prefix("PID", ""))
      },
      %{field: :clients_count, header: "Clients count"}
    ]
  end

  defp row_attrs(session) do
    [
      {"phx-click", "show_info"},
      {"phx-value-info", encode_pid(session[:pid])},
      {"phx-page-loading", true}
    ]
  end
end
