defmodule SpotifyWallWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # Database Metrics
      summary("spotify_wall.repo.query.total_time", unit: {:native, :millisecond}),
      summary("spotify_wall.repo.query.decode_time", unit: {:native, :millisecond}),
      summary("spotify_wall.repo.query.query_time", unit: {:native, :millisecond}),
      summary("spotify_wall.repo.query.queue_time", unit: {:native, :millisecond}),
      summary("spotify_wall.repo.query.idle_time", unit: {:native, :millisecond}),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),

      # Spotify
      summary("tesla.request.request_time",
      unit: {:native, :millisecond},
      tags: [:method, :url],
      tag_values: &tag_tesla_method_and_request_path/1)
    ]
  end

  defp tag_tesla_method_and_request_path(%{result: {_status, res}}) do
    Map.take(res, [:method, :url])
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {SpotifyWallWeb, :count_users, []}
    ]
  end
end
