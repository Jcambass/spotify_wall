defmodule SpotifyWall.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :nickname, :string
    field :token, :string

    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:nickname, :token])
    |> validate_required([:nickname, :token])
    |> unique_constraint(:nickname)
  end
end
