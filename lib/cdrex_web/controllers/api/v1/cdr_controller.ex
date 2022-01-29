defmodule CDRexWeb.Api.V1.CDRController do
  use CDRexWeb, :controller

  alias CDRex.CDRs

  filter_for(:create,
    required: [
      :client_name,
      :client_code,
      :carrier_name,
      :source_number,
      :destination_number,
      :direction,
      :service,
      :number_of_units,
      :success
    ]
  )

  def create(conn, params) do
    params = Map.put(params, :timestamp, NaiveDateTime.utc_now())

    with {:ok, [cdr]} <- CDRs.create(params) do
      conn
      |> put_status(:ok)
      |> render(cdr: cdr)
    end
  end
end
