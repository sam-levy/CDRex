defmodule CDRexWeb.Api.V1.CDRView do
  use CDRexWeb, :view

  def render("create.json", %{cdr: cdr}) do
    cdr
    |> render_one(__MODULE__, "cdr.json")
    |> handle_data()
  end

  def render("cdr.json", %{cdr: cdr}) do
    %{
      carrier_name: cdr.carrier_name,
      client_code: cdr.client_code,
      client_name: cdr.client_name,
      destination_number: cdr.destination_number,
      direction: cdr.direction,
      number_of_units: cdr.number_of_units,
      service: cdr.service,
      source_number: cdr.source_number,
      success: cdr.success,
      amount: cdr.amount,
      timestamp: cdr.timestamp
    }
  end

  defp handle_data(data), do: %{data: data}
end
