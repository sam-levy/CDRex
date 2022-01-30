defmodule CDRexWeb.Api.V1.ClientFeeController do
  use CDRexWeb, :controller

  alias CDRex.ClientFees

  filter_for(:import, required: [:file])

  def import(conn, %{file: %{path: file_path}}) do
    with {:ok, client_fees} <- ClientFees.create_from_csv(file_path) do
      conn
      |> put_status(:ok)
      |> render(client_fees: client_fees)
    end
  end
end
