defmodule CDRexWeb.Api.V1.CarrierRateControllerTest do
  use CDRexWeb.ConnCase, async: true

  describe "POST api/V1/carrier_rates/import [:import]" do
    test "import carrier rates from a CSV file", %{conn: conn} do
      path = Routes.carrier_rate_path(conn, :import)

      file = %Plug.Upload{
        filename: "buy_rates.csv",
        path: Path.absname("test/support/assets/buy_rates.csv"),
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
                   "carrier_name" => "Carrier B",
                   "direction" => "outbound",
                   "rate" => 0.004,
                   "service" => "mms",
                   "start_date" => "2020-01-01"
                 },
                 %{
                   "carrier_name" => "Carrier B",
                   "direction" => "outbound",
                   "rate" => 0.001,
                   "service" => "sms",
                   "start_date" => "2020-01-01"
                 },
                 %{
                   "carrier_name" => "Carrier B",
                   "direction" => "outbound",
                   "rate" => 0.0025,
                   "service" => "voice",
                   "start_date" => "2020-01-01"
                 },
                 %{
                   "carrier_name" => "Carrier A",
                   "direction" => "outbound",
                   "rate" => 0.004,
                   "service" => "mms",
                   "start_date" => "2020-01-01"
                 },
                 %{
                   "carrier_name" => "Carrier A",
                   "direction" => "outbound",
                   "rate" => 0.001,
                   "service" => "sms",
                   "start_date" => "2020-01-01"
                 },
                 %{
                   "carrier_name" => "Carrier A",
                   "direction" => "outbound",
                   "rate" => 0.003,
                   "service" => "voice",
                   "start_date" => "2020-01-01"
                 }
               ]
             }
    end

    test "when CSV file has invalid values", %{conn: conn} do
      path = Routes.carrier_rate_path(conn, :import)

      file = %Plug.Upload{
        filename: "cdrs.csv",
        path: Path.absname("test/support/assets/buy_rates_invalid_values.csv"),
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
                 "direction" => ["is invalid"],
                 "rate" => ["is invalid"],
                 "start_date" => ["is invalid"]
               },
               "message" => "Unprocessable entity"
             }
    end

    test "when file is invalid", %{conn: conn} do
      path = Routes.carrier_rate_path(conn, :import)

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
