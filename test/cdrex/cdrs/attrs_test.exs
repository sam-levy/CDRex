defmodule CDRex.CDRs.AttrsTest do
  use CDRex.DataCase, async: true

  alias CDRex.CDRs.Attrs

  describe "build/1" do
    test "builds am Attrs struct from a valid map" do
      cdr = %{
        "carrier" => "Carrier B",
        "client_code" => "BIZ00",
        "client_name" => "Biznode",
        "destination_number" => "17148943322",
        "direction" => "INBOUND",
        "number_of_units" => "10",
        "service_type" => "VOICE",
        "source_number" => "16197558541",
        "success" => "TRUE",
        "timestamp" => "31/12/2020 23:59:11"
      }

      assert Attrs.build(cdr) ==
               {:ok,
                %Attrs{
                  carrier_name: "Carrier B",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "17148943322",
                  direction: "inbound",
                  number_of_units: "10",
                  service: "voice",
                  source_number: "16197558541",
                  success: "true",
                  timestamp: ~N[2020-12-31 23:59:11]
                }}
    end

    test "builds a list of Attrs structs from a list of valid maps" do
      cdrs = [
        %{
          "carrier" => "Carrier B",
          "client_code" => "BIZ00",
          "client_name" => "Biznode",
          "destination_number" => "17148943322",
          "direction" => "INBOUND",
          "number_of_units" => "10",
          "service_type" => "VOICE",
          "source_number" => "16197558541",
          "success" => "TRUE",
          "timestamp" => "31/12/2020 23:59:11"
        },
        %{
          "carrier" => "Carrier A",
          "client_code" => "BIZ00",
          "client_name" => "Biznode",
          "destination_number" => "18014848755",
          "direction" => "OUTBOUND",
          "number_of_units" => "96",
          "service_type" => "VOICE",
          "source_number" => "17083986237",
          "success" => "TRUE",
          "timestamp" => "01/01/2021 00:05:26"
        }
      ]

      assert Attrs.build(cdrs) ==
               {:ok,
                [
                  %Attrs{
                    carrier_name: "Carrier A",
                    client_code: "BIZ00",
                    client_name: "Biznode",
                    destination_number: "18014848755",
                    direction: "outbound",
                    number_of_units: "96",
                    service: "voice",
                    source_number: "17083986237",
                    success: "true",
                    timestamp: ~N[2021-01-01 00:05:26]
                  },
                  %Attrs{
                    carrier_name: "Carrier B",
                    client_code: "BIZ00",
                    client_name: "Biznode",
                    destination_number: "17148943322",
                    direction: "inbound",
                    number_of_units: "10",
                    service: "voice",
                    source_number: "16197558541",
                    success: "true",
                    timestamp: ~N[2020-12-31 23:59:11]
                  }
                ]}
    end

    test "when one or more keys are missing" do
      cdr = %{
        "client_code" => "BIZ00",
        "client_name" => "Biznode",
        "destination_number" => "17148943322",
        "direction" => "INBOUND",
        "number_of_units" => "10",
        "service_type" => "VOICE",
        "source_number" => "16197558541",
        "success" => "TRUE",
        "timestamp" => "31/12/2020 23:59:11"
      }

      assert Attrs.build(cdr) == {:error, "missing required keys"}
    end

    test "ignores invalid keys" do
      cdr = %{
        "carrier" => "Carrier B",
        "client_code" => "BIZ00",
        "client_name" => "Biznode",
        "destination_number" => "17148943322",
        "direction" => "INBOUND",
        "number_of_units" => "10",
        "service_type" => "VOICE",
        "source_number" => "16197558541",
        "success" => "TRUE",
        "timestamp" => "31/12/2020 23:59:11",
        "INVALID_KEY" => "invalid value"
      }

      assert Attrs.build(cdr) ==
               {:ok,
                %Attrs{
                  carrier_name: "Carrier B",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "17148943322",
                  direction: "inbound",
                  number_of_units: "10",
                  service: "voice",
                  source_number: "16197558541",
                  success: "true",
                  timestamp: ~N[2020-12-31 23:59:11]
                }}
    end

    test "when timestamp format is invalid" do
      cdr = %{
        "carrier" => "Carrier B",
        "client_code" => "BIZ00",
        "client_name" => "Biznode",
        "destination_number" => "17148943322",
        "direction" => "INBOUND",
        "number_of_units" => "10",
        "service_type" => "VOICE",
        "source_number" => "16197558541",
        "success" => "TRUE",
        "timestamp" => "31-12-2020 23:59:11"
      }

      assert Attrs.build(cdr) == {:error, "invalid timestamp format"}
    end
  end
end
