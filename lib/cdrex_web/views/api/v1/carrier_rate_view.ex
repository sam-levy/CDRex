defmodule CDRexWeb.Api.V1.CarrierRateView do
  use CDRexWeb, :view

  def render("import.json", %{carrier_rates: carrier_rates}) do
    carrier_rates
    |> render_many(__MODULE__, "carrier_rate.json")
    |> handle_data()
  end

  def render("carrier_rate.json", %{carrier_rate: carrier_rate}) do
    %{
      carrier_name: carrier_rate.carrier_name,
      start_date: carrier_rate.start_date,
      rate: carrier_rate.rate,
      service: carrier_rate.service,
      direction: carrier_rate.direction
    }
  end

  defp handle_data(data), do: %{data: data}
end
