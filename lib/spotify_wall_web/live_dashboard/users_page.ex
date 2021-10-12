defmodule SpotifyWallWeb.LiveDashboard.UsersPage do
  use Phoenix.LiveDashboard.PageBuilder

  @impl true
  def menu_link(_, _) do
    {:ok, "Users"}
  end

  @impl true
  def render_page(_assigns) do
    table(
      columns: columns(),
      id: :users,
      row_fetcher: &fetch_users/2,
      rows_name: "users",
      title: "Users"
    )
  end

  defp fetch_users(%{sort_by: sort_by, sort_dir: sort_dir}, _node) do
    users =
      SpotifyWall.Stats.users_with_wall_count()
      |> Enum.map(fn {u, count} ->
        %{
          user_id: u.id,
          user_nickname: u.nickname,
          signed_up_at: u.inserted_at,
          walls_count: count
        }
      end)
      |> sort(sort_by, sort_dir)

    {users, length(users)}
  end

  defp sort(users, nil, _dir) do
    users
  end

  # TODO: Implement correct sorting for date values.
  defp sort(users, key, dir) do
    users
    |> Enum.sort_by(fn user -> Map.get(user, key) end)
    |> maybe_reverse(dir)
  end

  defp maybe_reverse(users, dir) do
    case dir do
      :asc -> users
      :desc -> Enum.reverse(users)
    end
  end

  defp columns do
    [
      %{field: :user_id, header: "ID", sortable: :asc},
      %{field: :user_nickname, header: "Nickname", sortable: :asc},
      %{field: :signed_up_at, header: "Signed Up At", sortable: :asc},
      %{field: :walls_count, header: "Walls count", sortable: :asc}
    ]
  end
end
