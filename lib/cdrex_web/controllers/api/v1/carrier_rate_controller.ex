defmodule CDRexWeb.Api.V1.CarrierRateController do
  use CDRexWeb, :controller

  alias CDRex.CarrierRates

  filter_for(:import, required: [:file])

  def import(conn, %{file: %{path: file_path}}) do
    with {:ok, carrier_rates} <- CarrierRates.create_from_csv(file_path) do
      conn
      |> put_status(:ok)
      |> render(carrier_rates: carrier_rates)
    end
  end
end
