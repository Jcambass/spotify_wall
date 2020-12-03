defmodule SpotifyWall.Spotify.Credentials do
  @enforce_keys [:token, :refresh_token]
  defstruct [:token, :refresh_token]

  def from_user(user) do
    %__MODULE__{
      token: user.token,
      refresh_token: user.refresh_token
    }
  end
end
