defmodule CDRex.CDRs.Attrs do
  @moduledoc """
  """

  alias CDRex.CDRs.CDR

  @enforce_keys CDR.fields()
  defstruct CDR.fields()

  def build(attrs_list) when is_list(attrs_list) do
    attrs_list
    |> Enum.reduce_while([], fn attrs, acc ->
      case build(attrs) do
        {:error, _} = error -> {:halt, error}
        {:ok, attrs} -> {:cont, [attrs | acc]}
      end
    end)
    |> case do
      {:error, _} = error -> error
      attrs -> {:ok, attrs}
    end
  end

  def build(%{
        "client_code" => client_code,
        "client_name" => client_name,
        "source_number" => source_number,
        "destination_number" => destination_number,
        "direction" => direction,
        "service_type" => service_type,
        "number_of_units" => number_of_units,
        "success" => success,
        "carrier" => carrier,
        "timestamp" => timestamp
      }) do
    case parse_timestamp(timestamp) do
      {:ok, parsed_timestamp} ->
        attrs = %{
          client_code: client_code,
          client_name: client_name,
          carrier_name: carrier,
          source_number: source_number,
          destination_number: destination_number,
          direction: String.downcase(direction),
          service: String.downcase(service_type),
          number_of_units: number_of_units,
          success: String.downcase(success),
          timestamp: parsed_timestamp
        }

        {:ok, struct(__MODULE__, attrs)}

      {:error, _} = error ->
        error
    end
  end

  def build(_attrs), do: {:error, "missing required keys"}

  defp parse_timestamp(timestamp) do
    with [date, time] <- String.split(timestamp, " "),
         {:ok, parsed_time} <- Time.from_iso8601(time),
         [day, month, year] <- String.split(date, "/"),
         {:ok, parsed_date} <-
           Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day)),
         {:ok, parsed_date_time} <- NaiveDateTime.new(parsed_date, parsed_time) do
      {:ok, parsed_date_time}
    else
      _ -> {:error, "invalid timestamp format"}
    end
  end
end