defmodule CDRex.CDRs.Reporter do
  import Ecto.Query

  alias CDRex.CDRs.CDR
  alias CDRex.Repo

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

    acc = %{total: %{count: 0, total_price: 0}}

    summary =
      Enum.reduce(
        grouped_aggregates,
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

    {:ok, summary}
  end

  def client_summary_by_month(_client_code, _month, _year), do: {:error, "invalid attrs"}
end
