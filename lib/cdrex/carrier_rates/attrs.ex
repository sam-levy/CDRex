defmodule CDRex.CarrierRates.Attrs do
  @moduledoc """
  """

  alias CDRex.CarrierRates.CarrierRate

  @enforce_keys CarrierRate.fields()
  defstruct CarrierRate.fields()

  def build(attrs_list) when is_list(attrs_list) do
    attrs_list
    |> Enum.reduce_while([], fn attrs, acc ->
      case build(attrs) do
        {:error, _} = error -> {:halt, error}
        {:ok, attrs} -> {:cont, attrs ++ acc}
      end
    end)
    |> case do
      {:error, _} = error -> error
      attrs -> {:ok, attrs}
    end
  end

  def build(
        %{
          "carrier_name" => carrier_name,
          "direction" => direction,
          "rating_start_date" => start_date
        } = attrs
      ) do
    base_attrs = %{
      carrier_name: carrier_name,
      start_date: start_date,
      direction: String.downcase(direction)
    }

    rate_attrs = Map.drop(attrs, ~w(carrier_name direction rating_start_date))

    with false <- rate_attrs == %{},
         attrs when is_list(attrs) <-
           Enum.reduce_while(rate_attrs, [], &handle_rate(&1, &2, base_attrs)) do
      {:ok, attrs}
    else
      true -> {:error, "missing rate keys"}
      {:error, _} = error -> error
    end
  end

  def build(_attrs), do: {:error, "missing required keys"}

  defp handle_rate({"mms_rate", rate}, acc, base_attrs) do
    attrs = struct(__MODULE__, Map.merge(base_attrs, %{service: :mms, rate: rate}))

    {:cont, [attrs | acc]}
  end

  defp handle_rate({"sms_rate", rate}, acc, base_attrs) do
    attrs = struct(__MODULE__, Map.merge(base_attrs, %{service: :sms, rate: rate}))

    {:cont, [attrs | acc]}
  end

  defp handle_rate({"voice_rate", rate}, acc, base_attrs) do
    attrs = struct(__MODULE__, Map.merge(base_attrs, %{service: :voice, rate: rate}))

    {:cont, [attrs | acc]}
  end

  defp handle_rate(_invalid_kv, _acc, _base_attrs) do
    {:halt, {:error, "invalid key"}}
  end
end
