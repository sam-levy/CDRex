defmodule CDRex.ClientFees.Attrs do
  @moduledoc """
  """

  alias CDRex.ClientFees.ClientFee

  @enforce_keys ClientFee.fields()
  defstruct ClientFee.fields()

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
          "client_code" => client_code,
          "direction" => direction,
          "price_start_date" => start_date
        } = attrs
      ) do
    base_attrs = %{
      client_code: client_code,
      start_date: start_date,
      direction: String.downcase(direction)
    }

    fee_attrs = Map.drop(attrs, ~w(client_code direction price_start_date))

    with false <- fee_attrs == %{},
         attrs when is_list(attrs) <-
           Enum.reduce_while(fee_attrs, [], &handle_fee(&1, &2, base_attrs)) do
      {:ok, attrs}
    else
      true -> {:error, "missing fee keys"}
      {:error, _} = error -> error
    end
  end

  def build(_attrs), do: {:error, "missing required keys"}

  defp handle_fee({"mms_fee", fee}, acc, base_attrs) do
    attrs = struct(__MODULE__, Map.merge(base_attrs, %{service: :mms, fee: fee}))

    {:cont, [attrs | acc]}
  end

  defp handle_fee({"sms_fee", fee}, acc, base_attrs) do
    attrs = struct(__MODULE__, Map.merge(base_attrs, %{service: :sms, fee: fee}))

    {:cont, [attrs | acc]}
  end

  defp handle_fee({"voice_fee", fee}, acc, base_attrs) do
    attrs = struct(__MODULE__, Map.merge(base_attrs, %{service: :voice, fee: fee}))

    {:cont, [attrs | acc]}
  end

  defp handle_fee(_invalid_kv, _acc, _base_attrs) do
    {:halt, {:error, "invalid key"}}
  end
end
