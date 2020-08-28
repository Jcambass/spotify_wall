defmodule UnixTimestamp do
  @behaviour Ecto.Type
  def type, do: :naive_datetime

  def cast(timestamp) when is_integer(timestamp) do
    case DateTime.from_unix(timestamp) do
      {:ok, date} -> {:ok, date}
      {:error, reason} -> {:error, reason}
    end
  end

  def cast(%DateTime{} = date) do
    {:ok, date}
  end

  def cast(_), do: :error

  def dump(value), do: Ecto.Type.dump(:utc_datetime, value)

  def load(value), do: Ecto.Type.load(:utc_datetime, value)
end
