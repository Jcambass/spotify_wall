# SpotifyWall

Spotify Wall is a small side project mine which allows you to create groups for you and your friends or coworkers in order to share the current song you’re listing to on spotify.

## How it works


### Signup
You sign up with your Spotify account.

![screencapture-spotifywall-2021-10-12-17_05_41](https://user-images.githubusercontent.com/3436381/136981604-291a9b2f-a338-499d-bd6d-c0dead666a79.png)

### Walls

A wall is like a group where you can invite other people (they also need to have a Spotify account).

On the dashboard you will see each wall you've joined.
You can create a new wall by using the `+` card.

![image](https://user-images.githubusercontent.com/3436381/136983048-983263fd-34f0-4d23-ad54-5ab4bdcfedd9.png)

The wall will show what each member is currently listening to.

![image](https://user-images.githubusercontent.com/3436381/136983271-cba33727-15d6-4b20-9fb7-f8b068fdcc0e.png)


### Manage Members

The creator of the wall can invite people with a per-wall invitation link.

![image](https://user-images.githubusercontent.com/3436381/136982233-8d64bddc-1f88-4cf3-803c-bb03dfa4f810.png)


He also has the ability to remove people from the wall.

![image](https://user-images.githubusercontent.com/3436381/136982385-86302c0f-c4bf-4b87-a316-4dfb1688826d.png)

If for whatever reason you want prevent people with the invitation link from joining, the owner of the wall can generate a new invitation link.

![image](https://user-images.githubusercontent.com/3436381/136982419-88b2b6e3-97e3-4a43-a210-026e6f74fb02.png)


### Disable Sharing for a given Wall

You can always stop sharing to a wall without actually leaving the wall by using the `Stop Sharing` feature.

![image](https://user-images.githubusercontent.com/3436381/136982836-883006bd-2c56-4520-b1c4-74d6eeb2fa82.png)

To start sharing again the `Start Sharing` feature can be used.

![image](https://user-images.githubusercontent.com/3436381/136982892-ece5ed55-7fb6-4d07-97b7-9c07d94e15d0.png)

### Listening to Previews (WIP)

For some songs you can play a preview of the song by clicking the cover image.

## To run SpotifyWall yourself

  * Install elixir, erlang and nodejs
  * Install and configure postgres
  * Setup an OAuth app on Spotify and export `SPOTIFY_CLIENT_ID` and `SPOTIFY_CLIENT_SECRET`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
