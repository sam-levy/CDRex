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

  filter_for(:import, required: [:file])

  filter_for(:client_summary_by_month,
    required: [
      :client_code,
      {:month, :integer},
      {:year, :integer}
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

  def import(conn, %{file: %{path: file_path}}) do
    with {:ok, cdrs} <- CDRs.create_from_csv(file_path) do
      conn
      |> put_status(:ok)
      |> render(cdrs: cdrs)
    end
  end

  def client_summary_by_month(conn, %{client_code: client_code, month: month, year: year}) do
    with {:ok, summary} <- CDRs.client_summary_by_month(client_code, month, year) do
      conn
      |> put_status(:ok)
      |> json(%{data: summary})
    end
  end
end
