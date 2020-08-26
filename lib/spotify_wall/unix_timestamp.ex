defmodule UnixTimestamp do
  @behaviour Ecto.Type
  def type, do: :naive_datetime

  def cast(timestamp) when is_integer(timestamp) do
    case DateTime.from_unix(timestamp) do
      {:ok, date} -> {:ok, DateTime.to_naive(date)}
      {:error, reason} -> {:error, reason}
    end
  end

  def cast(_), do: :error

  def dump(value), do: Ecto.Type.dump(:naive_datetime, value)

  def load(value), do: Ecto.Type.load(:naive_datetime, value)
end
