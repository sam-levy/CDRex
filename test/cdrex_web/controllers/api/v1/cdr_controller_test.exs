defmodule CDRexWeb.Api.V1.CDRControllerTest do
  use CDRexWeb.ConnCase, async: true

  def insert_rates(_context) do
    insert(:carrier_rate,
      carrier_name: "Carrier A",
      start_date: ~D[2021-01-01],
      service: :voice,
      direction: :outbound,
      rate: 0.001
    )

    insert(:carrier_rate,
      carrier_name: "Carrier B",
      start_date: ~D[2021-01-01],
      service: :voice,
      direction: :outbound,
      rate: 0.002
    )

    insert(:client_fee,
      client_code: "LIB25",
      start_date: ~D[2021-01-01],
      service: :voice,
      direction: :outbound,
      fee: 0.03
    )

    insert(:client_fee,
      client_code: "BIZ00",
      start_date: ~D[2021-01-01],
      service: :voice,
      direction: :outbound,
      fee: 0.04
    )

    :ok
  end

  describe "POST api/V1/cdrs [:create]" do
    setup :insert_rates

    test "creates a CDR", %{conn: conn} do
      path = Routes.cdr_path(conn, :create)

      params = %{
        "carrier_name" => "Carrier A",
        "client_code" => "BIZ00",
        "client_name" => "Biznode",
        "destination_number" => "17148943322",
        "direction" => "outbound",
        "number_of_units" => "10",
        "service" => "voice",
        "source_number" => "16197558541",
        "success" => "true"
      }

      response =
        conn
        |> post(path, params)
        |> json_response(200)

      assert %{
               "data" => %{
                 "carrier_name" => "Carrier A",
                 "client_code" => "BIZ00",
                 "client_name" => "Biznode",
                 "destination_number" => "17148943322",
                 "direction" => "outbound",
                 "number_of_units" => 10,
                 "service" => "voice",
                 "source_number" => "16197558541",
                 "success" => true,
                 "amount" => 0.41,
                 "timestamp" => timestamp
               }
             } = response

      assert {:ok, _} = NaiveDateTime.from_iso8601(timestamp)
    end

    test "when client does't exist", %{conn: conn} do
      path = Routes.cdr_path(conn, :create)

      params = %{
        "carrier_name" => "Carrier C",
        "client_code" => "BIZ00",
        "client_name" => "Biznode",
        "destination_number" => "17148943322",
        "direction" => "outbound",
        "number_of_units" => "10",
        "service" => "voice",
        "source_number" => "16197558541",
        "success" => "true"
      }

      response =
        conn
        |> post(path, params)
        |> json_response(422)

      assert response == %{
               "errors" => %{"amount" => ["carrier rate not found for the CDR"]},
               "message" => "Unprocessable entity"
             }
    end

    test "returns errors for missing required params", %{conn: conn} do
      path = Routes.cdr_path(conn, :create)

      response =
        conn
        |> post(path, %{})
        |> json_response(400)

      assert response == %{
               "errors" => %{
                 "carrier_name" => "is required",
                 "client_code" => "is required",
                 "client_name" => "is required",
                 "destination_number" => "is required",
                 "direction" => "is required",
                 "number_of_units" => "is required",
                 "service" => "is required",
                 "source_number" => "is required",
                 "success" => "is required"
               },
               "message" => "Bad request"
             }
    end

    test "returns errors for invalid params", %{conn: conn} do
      path = Routes.cdr_path(conn, :create)

      params = %{
        "carrier_name" => "Carrier A",
        "client_code" => "BIZ00",
        "client_name" => "Biznode",
        "destination_number" => "17148943322",
        "direction" => "INVALID",
        "number_of_units" => "10",
        "service" => "INVALID",
        "source_number" => "16197558541",
        "success" => "INVALID"
      }

      response =
        conn
        |> post(path, params)
        |> json_response(422)

      assert response == %{
               "errors" => %{
                 "direction" => ["is invalid"],
                 "service" => ["is invalid"],
                 "success" => ["is invalid"]
               },
               "message" => "Unprocessable entity"
             }
    end
  end

  describe "POST api/V1/cdrs/import [:import]" do
    setup :insert_rates

    test "import CDRs from a CSV file", %{conn: conn} do
      path = Routes.cdr_path(conn, :import)

      file = %Plug.Upload{
        filename: "cdrs.csv",
        path: Path.absname("test/support/assets/cdrs.csv"),
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
                   "amount" => 1.68,
                   "carrier_name" => "Carrier B",
                   "client_code" => "BIZ00",
                   "client_name" => "Biznode",
                   "destination_number" => "12703665756",
                   "direction" => "outbound",
                   "number_of_units" => 40,
                   "service" => "voice",
                   "source_number" => "16013167018",
                   "success" => true,
                   "timestamp" => "2021-01-01T00:05:49"
                 },
                 %{
                   "amount" => 1.23,
                   "carrier_name" => "Carrier A",
                   "client_code" => "BIZ00",
                   "client_name" => "Biznode",
                   "destination_number" => "12705575114",
                   "direction" => "outbound",
                   "number_of_units" => 30,
                   "service" => "voice",
                   "source_number" => "19803395703",
                   "success" => true,
                   "timestamp" => "2021-01-01T00:07:01"
                 },
                 %{
                   "amount" => 0.64,
                   "carrier_name" => "Carrier B",
                   "client_code" => "LIB25",
                   "client_name" => "Lib Group",
                   "destination_number" => "12705575114",
                   "direction" => "outbound",
                   "number_of_units" => 20,
                   "service" => "voice",
                   "source_number" => "16619525945",
                   "success" => true,
                   "timestamp" => "2021-01-01T00:02:29"
                 },
                 %{
                   "amount" => 0.31,
                   "carrier_name" => "Carrier A",
                   "client_code" => "LIB25",
                   "client_name" => "Lib Group",
                   "destination_number" => "17066135090",
                   "direction" => "outbound",
                   "number_of_units" => 10,
                   "service" => "voice",
                   "source_number" => "12159538568",
                   "success" => true,
                   "timestamp" => "2021-01-01T00:01:03"
                 }
               ]
             }
    end

    test "when CSV file has invalid values", %{conn: conn} do
      path = Routes.cdr_path(conn, :import)

      file = %Plug.Upload{
        filename: "cdrs.csv",
        path: Path.absname("test/support/assets/cdrs_invalid_values.csv"),
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
               "errors" => %{"service" => ["is invalid"], "success" => ["is invalid"]},
               "message" => "Unprocessable entity"
             }
    end

    test "when file is invalid", %{conn: conn} do
      path = Routes.cdr_path(conn, :import)

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

  describe "GET api/V1/cdrs/client_summary_by_month [:client_summary_by_month]" do
    test "returns a summary by client and month", %{conn: conn} do
      insert(:cdr,
        client_code: "BIZ00",
        service: :voice,
        amount: 30.0,
        timestamp: ~N[2021-01-01 00:00:00]
      )

      insert(:cdr,
        client_code: "BIZ00",
        service: :sms,
        amount: 30.0,
        timestamp: ~N[2021-01-01 00:00:00]
      )

      insert(:cdr,
        client_code: "BIZ00",
        service: :mms,
        amount: 35.0,
        timestamp: ~N[2021-01-01 00:00:00]
      )

      path = Routes.cdr_path(conn, :client_summary_by_month)

      params = %{
        "client_code" => "BIZ00",
        "month" => "1",
        "year" => "2021"
      }

      response =
        conn
        |> get(path, params)
        |> json_response(200)

      assert response == %{
               "data" => %{
                 "voice" => %{"count" => 1, "total_price" => 30.0},
                 "sms" => %{"count" => 1, "total_price" => 30.0},
                 "mms" => %{"count" => 1, "total_price" => 35.0},
                 "total" => %{"count" => 3, "total_price" => 95.0}
               }
             }
    end

    test "when params are not given", %{conn: conn} do
      insert(:cdr,
        client_code: "BIZ00",
        service: :voice,
        amount: 30.0,
        timestamp: ~N[2021-01-01 00:00:00]
      )

      insert(:cdr,
        client_code: "BIZ00",
        service: :sms,
        amount: 30.0,
        timestamp: ~N[2021-01-01 00:00:00]
      )

      insert(:cdr,
        client_code: "BIZ00",
        service: :mms,
        amount: 35.0,
        timestamp: ~N[2021-01-01 00:00:00]
      )

      path = Routes.cdr_path(conn, :client_summary_by_month)

      response =
        conn
        |> get(path, %{})
        |> json_response(400)

      assert response == %{
               "errors" => %{
                 "client_code" => "is required",
                 "month" => "is required",
                 "year" => "is required"
               },
               "message" => "Bad request"
             }
    end

    test "when params are invalid", %{conn: conn} do
      insert(:cdr,
        client_code: "BIZ00",
        service: :voice,
        amount: 30.0,
        timestamp: ~N[2021-01-01 00:00:00]
      )

      insert(:cdr,
        client_code: "BIZ00",
        service: :sms,
        amount: 30.0,
        timestamp: ~N[2021-01-01 00:00:00]
      )

      insert(:cdr,
        client_code: "BIZ00",
        service: :mms,
        amount: 35.0,
        timestamp: ~N[2021-01-01 00:00:00]
      )

      path = Routes.cdr_path(conn, :client_summary_by_month)

      params = %{
        "client_code" => "BIZ00",
        "month" => "13",
        "year" => "2021"
      }

      response =
        conn
        |> get(path, params)
        |> json_response(422)

      assert response == %{
               "errors" => "invalid attrs",
               "message" => "Unprocessable entity"
             }
    end
  end
end
