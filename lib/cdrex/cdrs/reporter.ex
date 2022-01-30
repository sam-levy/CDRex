defmodule CDRex.CDRs.Reporter do
  @moduledoc """
    Functions to generate reports related to CDRs.
  """

  import Ecto.Query

  alias CDRex.CDRs.CDR
  alias CDRex.Repo

  @doc """
    Returns a map containing contaning the count and total amount of successful operations
    per service type for a client and month.

    Return example:

    ```
    &{
        service_1 %{
            count: 1,
            total_price: 1.5
        },
        service_2: %{
            count: 1,
            total_price: 1.5
        },
        service_3: %{
            count: 1,
            total_price: 1.5
        },
        total: %{
            count: 3,
            total_price: 4.5
        }
    }
    ```
  """
  def client_summary_by_month(client_code, month, year)
      when is_binary(client_code) and is_integer(month) and is_integer(year) and month <= 12 do
    grouped_aggregates =
      CDR
      |> where(client_code: ^client_code)
      |> where(success: true)
      |> where([cdr], fragment("EXTRACT(MONTH FROM timestamp) = ?", ^month))
      |> where([cdr], fragment("EXTRACT(YEAR FROM timestamp) = ?", ^year))
      |> group_by(:service)
      |> select([cdr], %{service: cdr.service, count: count(cdr), total_price: sum(cdr.amount)})
      |> Repo.all()

    acc = %{total: %{count: 0, total_price: 0.0}}

    summary =
      grouped_aggregates
      |> Enum.reduce(
        acc,
        fn %{
             count: service_count,
             service: service,
             total_price: service_total_price
           },
           %{total: %{count: count, total_price: total_price}} = acc ->
          acc
          |> Map.put(service, %{count: service_count, total_price: service_total_price})
          |> Map.put(:total, %{
            count: count + service_count,
            total_price: total_price + service_total_price
          })
        end
      )
      |> Enum.reduce(%{}, fn {service, summary}, acc ->
        rounded_summary = %{summary | total_price: Float.round(summary.total_price, 4)}

        Map.put(acc, service, rounded_summary)
      end)

    {:ok, summary}
  end

  def client_summary_by_month(_client_code, _month, _year), do: {:error, "invalid attrs"}
end
