defmodule CDRexWeb.Api.V1.ClientFeeControllerTest do
  use CDRexWeb.ConnCase, async: true

  describe "POST api/V1/client_fees/import [:import]" do
    test "import client fees from a CSV file", %{conn: conn} do
      path = Routes.client_fee_path(conn, :import)

      file = %Plug.Upload{
        filename: "sell_rates.csv",
        path: Path.absname("test/support/assets/sell_rates.csv"),
        content_type: "text/csv"
      }

      params = %{
        "file" => file
      }

      response =
        conn
        |> post(path, params)
        |> json_response(200)

      assert response == %{
               "data" => [
                 %{
                   "client_code" => "LIB25",
                   "direction" => "outbound",
                   "fee" => 0.03,
                   "service" => "mms",
                   "start_date" => "2020-01-01"
                 },
                 %{
                   "client_code" => "LIB25",
                   "direction" => "outbound",
                   "fee" => 0.02,
                   "service" => "sms",
                   "start_date" => "2020-01-01"
                 },
                 %{
                   "client_code" => "LIB25",
                   "direction" => "outbound",
                   "fee" => 0.04,
                   "service" => "voice",
                   "start_date" => "2020-01-01"
                 },
                 %{
                   "client_code" => "RAB11",
                   "direction" => "outbound",
                   "fee" => 0.01,
                   "service" => "mms",
                   "start_date" => "2020-01-01"
                 },
                 %{
                   "client_code" => "RAB11",
                   "direction" => "outbound",
                   "fee" => 0.01,
                   "service" => "sms",
                   "start_date" => "2020-01-01"
                 },
                 %{
                   "client_code" => "RAB11",
                   "direction" => "outbound",
                   "fee" => 0.01,
                   "service" => "voice",
                   "start_date" => "2020-01-01"
                 }
               ]
             }
    end

    test "when CSV file has invalid values", %{conn: conn} do
      path = Routes.client_fee_path(conn, :import)

      file = %Plug.Upload{
        filename: "cdrs.csv",
        path: Path.absname("test/support/assets/sell_rates_invalid_values.csv"),
        content_type: "text/csv"
      }

      params = %{
        "file" => file
      }

      response =
        conn
        |> post(path, params)
        |> json_response(422)

      assert response == %{
               "errors" => %{
                 "direction" => ["is invalid"]
               },
               "message" => "Unprocessable entity"
             }
    end

    test "when file is invalid", %{conn: conn} do
      path = Routes.client_fee_path(conn, :import)

      file = %Plug.Upload{
        filename: "cdrs.csv",
        path: Path.absname("test/support/assets/tsg.png"),
        content_type: "text/csv"
      }

      params = %{
        "file" => file
      }

      response =
        conn
        |> post(path, params)
        |> json_response(422)

      assert response == %{
               "errors" => "invalid file",
               "message" => "Unprocessable entity"
             }
    end
  end
end
