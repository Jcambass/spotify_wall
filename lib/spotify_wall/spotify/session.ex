defmodule SpotifyWall.Spotify.Session do
  @moduledoc """
  This module implements a state machine mapped to a user session, wrapping
  interaction with the Spotify API.

  ## General structure

  The state machine uses `GenStateMachine` to model its lifecycle.

  If you're not familiar with the `gen_statem` behaviour (which powers
  `GenStateMachine`), it's beneficial to read
  <http://erlang.org/doc/design_principles/statem.html> before proceeding
  further.

  The state machine uses the `handle_event_function` callback mode and has 3
  states: `:not_authenticated`, `:authenticated` and `:expired`.

  ```
                                ┌─────────────────┐
                                │Not authenticated│
                                └─────────────────┘
                                         │
                                         │
                                         ▼
                                ┌─────────────────┐
                                │     Refresh     │
                                └─────────────────┘
                                         │
                                         │
                                         ▼
                               ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─
                      ┌────────    Authenticate   │─────────┐
                      │        └ ─ ─ ─ ─ ─ ─ ─ ─ ─          │
                      │                  │                  │
                  Success             Token             Invalid
                      │              expired             token
                      │                  │                  │
                      │                  │                  │
                      ▼                  ▼                  ▼
               ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
               │Authenticated│    │   Expired   │    │    Stop     │
               └─────────────┘    └─────────────┘    └─────────────┘
                      ▲                  │                  ▲
                      │              Get new                │
                  Success             token                 │
                      │    ┌ ─ ─ ─ ─     │                  │
                      └──── Refresh │◀───┘                  │
                           └ ─ ─ ─ ─                        │
                                │                           │
                                │          Invalid          │
                                └──────────refresh ─────────┘
                                            token
  ```

  When the process starts, it retrieves a new token based on the stored refresh token,
  then it tries to authenticate against the Spotify API
  using the provided credentials. If successful, it enters the authenticated
  state, where all API functions can be executed correctly.

  Any error that indicates that credentials are invalid causes the process to
  stop. Any transient network error automatically triggers a delayed retry,
  which guarantees that _eventually_ the state machine reaches the
  authenticated state.

  ## Data lifecycle

  Aside from acting as an API client for on-demand operations (e.g. search,
  play/pause, etc.), the state machine also regularly polls the Spotify API for
  current player status and connected devices. Both pieces of information are
  kept in the state machine data for fast read and corresponding events are
  broadcasted when they change.

  Automatic data fetch is performed after successful authentication (via an
  `internal` event) and then scheduled via a `state_timeout` event. Once
  handled, the scheduled event requeues itself via the same `state_timeout` events.

  Usage of `state_timeout` events complies with the general state machine: if
  at any point the machine enters the expired state, any queued `state_timeout`
  event is automatically expired.

  Automatic fetching will resume once the machine enters the authenticated state.

  ## Subscriptions

  Multiple processes are able to subscribe to the events keyed by the session id.

  Broadcast and subscribe are implemented via `Phoenix.PubSub`, however the
  state machine maintains its own set of monitored processes subscribed to the session
  id.

  Subscription tracking is necessary to implementing automatic termination of a
  state machine after a period of inactivity. Without that, the state machine would
  indefinitely poll the Spotify API, even when no client is interested into the
  topic, until a crash error or a node reboot.

  Every 30 seconds, the state machine fires a named `timeout` event, checking if
  there's any subscribed process. If not, it terminates. Subscribed processes
  are monitored, so when they terminate, their exit is handled by the state machine,
  which removes them from its data.

  Usage of named `timeout` events is necessary, as they're guaranteed to fire
  irrespectively of state changes.
  """
  use GenStateMachine, restart: :temporary

  alias SpotifyWall.Spotify.SessionRegistry
  alias SpotifyWall.Spotify.Client
  alias Phoenix.PubSub

  @default_timeouts %{
    refresh: 10_000,
    retry: 5000,
    inactivity: 30_000
  }

  defstruct session_id: nil,
            credentials: nil,
            user: nil,
            now_playing: nil,
            subscribers: MapSet.new(),
            timeouts: @default_timeouts

  ################################################################################
  ################################## PUBLIC API ##################################
  ################################################################################

  def start_link({session_id, credentials}),
    do: start_link(session_id, credentials, timeouts: @default_timeouts)

  def start_link({session_id, credentials, start_opts}),
    do: start_link(session_id, credentials, start_opts)

  def start_link(session_id, credentials, start_opts) do
    GenStateMachine.start_link(__MODULE__, {session_id, credentials, start_opts},
      name: via(session_id)
    )
  end

  def setup(session_id, credentials) do
    SpotifyWall.Spotify.Supervisor.ensure_session(session_id, credentials)
  end

  def subscribe(session_id) do
    PubSub.subscribe(SpotifyWall.PubSub, session_id)
    GenStateMachine.call(via(session_id), {:subscribe, self()})
  end

  def subscribers_count(session_id) do
    GenStateMachine.call(via(session_id), :subscribers_count)
  end

  def broadcast(session_id, message) do
    PubSub.broadcast(SpotifyWall.PubSub, session_id, message)
  end

  def now_playing(session_id) do
    GenStateMachine.call(via(session_id), :now_playing)
  end

  def full_user_name(session_id) do
    GenStateMachine.call(via(session_id), :full_user_name)
  end

  ################################################################################
  ################################## CALLBACKS ###################################
  ################################################################################

  @doc false
  @impl true
  def init({session_id, credentials, start_opts}) do
    timeouts = Keyword.get(start_opts, :timeouts, @default_timeouts)
    data = %__MODULE__{session_id: session_id, credentials: credentials, timeouts: timeouts}
    {:ok, :not_authenticated, data, {:next_event, :internal, :refresh}}
  end

  @doc false
  @impl true
  def handle_event(event_type, :refresh, state, data) when state in [:not_authenticated, :expired]
      when event_type in [:internal, :state_timeout] do
    case Client.get_token(data.credentials.refresh_token) do
      {:ok, new_credentials} ->
        data = %{data | credentials: new_credentials}
        {:next_state, :not_authenticated, data, {:next_event, :internal, :authenticate}}

      {:error, status} when is_integer(status) ->
        {:stop, :invalid_refresh_token}

      # abnormal http error, retry in 5 seconds
      {:error, _reason} ->
        {:keep_state_and_data, {:state_timeout, data.timeouts.retry, :refresh}}
    end
  end

  def handle_event(event_type, :authenticate, :not_authenticated, data)
      when event_type in [:internal, :state_timeout] do
    case Client.get_profile(data.credentials.token) do
      {:ok, user} ->
        data = %{data | user: user}

        actions = [
          {:next_event, :internal, :get_now_playing},
          {:state_timeout, data.timeouts.refresh, :refresh_data},
          {{:timeout, :inactivity}, data.timeouts.inactivity, :expired}
        ]

        {:next_state, :authenticated, data, actions}

      {:error, :invalid_token} ->
        {:stop, :invalid_token}

      # abnormal http error, retry in 5 seconds
      {:error, _reason} ->
        action = {:state_timeout, data.timeouts.retry, :authenticate}
        {:keep_state_and_data, action}
    end
  end

  def handle_event(:internal, :get_now_playing, :authenticated, data) do
    case Client.now_playing(data.credentials.token) do
      {:error, :invalid_token} ->
        {:stop, :invalid_token}

      {:error, :expired_token} ->
        action = {:next_event, :internal, :refresh}
        {:next_state, :expired, data, action}

      # abnormal http error, retry in 5 seconds
      {:error, _reason} ->
        action = {:state_timeout, data.timeouts.retry, :get_now_playing}
        {:keep_state_and_data, action}

      {:ok, now_playing} ->
        if data.now_playing !== now_playing do
          broadcast(data.session_id, {:now_playing, data.session_id, now_playing})
        end

        data = %{data | now_playing: now_playing}

        {:keep_state, data}
    end
  end

  def handle_event(:state_timeout, :refresh_data, :authenticated, data) do
    with {:ok, now_playing} <- Client.now_playing(data.credentials.token) do
      if data.now_playing !== now_playing do
        broadcast(data.session_id, {:now_playing, data.session_id, now_playing})
      end

      data = %{data | now_playing: now_playing}

      action = {:state_timeout, data.timeouts.refresh, :refresh_data}

      {:keep_state, data, action}
    else
      {:error, :invalid_token} ->
        {:stop, :invalid_token}

      {:error, :expired_token} ->
        action = {:next_event, :internal, :refresh}
        {:next_state, :expired, data, action}

      # abnormal http error, retry in 5 seconds
      {:error, _reason} ->
        action = {:state_timeout, data.timeouts.retry, :refresh_data}
        {:keep_state_and_data, action}
    end
  end

  def handle_event({:call, from}, {:subscribe, pid}, _state, data) do
    new_subscribers = MapSet.put(data.subscribers, pid)
    Process.monitor(pid)
    action = {:reply, from, :ok}
    {:keep_state, %{data | subscribers: new_subscribers}, action}
  end

  def handle_event({:call, from}, :subscribers_count, _state, data) do
    action = {:reply, from, MapSet.size(data.subscribers)}
    {:keep_state_and_data, action}
  end

  def handle_event({:call, from}, :full_user_name, :authenticated, data) do
    name =
      case data.user do
        nil -> data.session_id
        user -> user.name
      end

    action = {:reply, from, name}
    {:keep_state_and_data, action}
  end

  def handle_event({:call, from}, msg, :authenticated, data) do
    handle_authenticated_call(from, msg, data)
  end

  def handle_event({:call, from}, _request, _state, _data) do
    action = {:reply, from, {:error, :not_authenticated}}
    {:keep_state_and_data, action}
  end

  def handle_event({:timeout, :inactivity}, :expired, _state, data) do
    if MapSet.size(data.subscribers) == 0 do
      {:stop, :normal}
    else
      action = {{:timeout, :inactivity}, data.timeouts.inactivity, :expired}
      {:keep_state_and_data, action}
    end
  end

  def handle_event(:info, {:DOWN, _ref, :process, pid, _reason}, _state, data) do
    new_subscribers = MapSet.delete(data.subscribers, pid)

    {:keep_state, %{data | subscribers: new_subscribers}}
  end

  ################################################################################
  ########################### INTERNAL IMPLEMENTATION ############################
  ################################################################################

  defp handle_authenticated_call(from, :now_playing, data) do
    action = {:reply, from, data.now_playing}
    {:keep_state_and_data, action}
  end

  defp via(session_id) do
    {:via, Registry, {SessionRegistry, session_id}}
  end
end
