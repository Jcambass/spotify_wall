defmodule SpotifyWall.Spotify.Credentials do
  @enforce_keys [:refresh_token]
  defstruct [:refresh_token, :token]

  def from_user(user) do
    %__MODULE__{
      refresh_token: user.refresh_token
    }
  end
end
