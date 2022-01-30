defmodule CDRexWeb.Api.V1.ClientFeeView do
  use CDRexWeb, :view

  def render("import.json", %{client_fees: client_fees}) do
    client_fees
    |> render_many(__MODULE__, "client_fee.json")
    |> handle_data()
  end

  def render("client_fee.json", %{client_fee: client_fee}) do
    %{
      client_code: client_fee.client_code,
      start_date: client_fee.start_date,
      fee: client_fee.fee,
      service: client_fee.service,
      direction: client_fee.direction
    }
  end

  defp handle_data(data), do: %{data: data}
end
