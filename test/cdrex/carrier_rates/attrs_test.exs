defmodule CDRex.CarrierRates.AttrsTest do
  use CDRex.DataCase, async: true

  alias CDRex.CarrierRates.Attrs

  describe "build/1" do
    test "builds a list of Attrs structs from a valid map" do
      carrier_rates = %{
        "carrier_name" => "Carrier B",
        "direction" => "OUTBOUND",
        "mms_rate" => "0.004",
        "rating_start_date" => "2020-01-01",
        "sms_rate" => "0.001",
        "voice_rate" => "0.0025"
      }

      assert Attrs.build(carrier_rates) ==
               {:ok,
                [
                  %Attrs{
                    carrier_name: "Carrier B",
                    direction: "outbound",
                    rate: "0.0025",
                    service: :voice,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    carrier_name: "Carrier B",
                    direction: "outbound",
                    rate: "0.001",
                    service: :sms,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    carrier_name: "Carrier B",
                    direction: "outbound",
                    rate: "0.004",
                    service: :mms,
                    start_date: "2020-01-01"
                  }
                ]}
    end

    test "builds a list of Attrs structs from a list of valid maps" do
      carrier_rates = [
        %{
          "carrier_name" => "Carrier B",
          "direction" => "OUTBOUND",
          "mms_rate" => "0.004",
          "rating_start_date" => "2020-01-01",
          "sms_rate" => "0.001",
          "voice_rate" => "0.0025"
        },
        %{
          "carrier_name" => "Carrier A",
          "direction" => "OUTBOUND",
          "mms_rate" => "0.004",
          "rating_start_date" => "2020-01-01",
          "sms_rate" => "0.001",
          "voice_rate" => "0.003"
        }
      ]

      assert Attrs.build(carrier_rates) ==
               {:ok,
                [
                  %Attrs{
                    carrier_name: "Carrier A",
                    direction: "outbound",
                    rate: "0.003",
                    service: :voice,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    carrier_name: "Carrier A",
                    direction: "outbound",
                    rate: "0.001",
                    service: :sms,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    carrier_name: "Carrier A",
                    direction: "outbound",
                    rate: "0.004",
                    service: :mms,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    carrier_name: "Carrier B",
                    direction: "outbound",
                    rate: "0.0025",
                    service: :voice,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    carrier_name: "Carrier B",
                    direction: "outbound",
                    rate: "0.001",
                    service: :sms,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    carrier_name: "Carrier B",
                    direction: "outbound",
                    rate: "0.004",
                    service: :mms,
                    start_date: "2020-01-01"
                  }
                ]}
    end

    test "builds a list of Attrs structs from a parcial valid map" do
      carrier_rates = %{
        "carrier_name" => "Carrier B",
        "direction" => "OUTBOUND",
        "mms_rate" => "0.004",
        "rating_start_date" => "2020-01-01"
      }

      assert Attrs.build(carrier_rates) ==
               {:ok,
                [
                  %Attrs{
                    carrier_name: "Carrier B",
                    direction: "outbound",
                    rate: "0.004",
                    service: :mms,
                    start_date: "2020-01-01"
                  }
                ]}
    end

    test "when `carrier_name` key is missing" do
      carrier_rates = %{
        "direction" => "OUTBOUND",
        "mms_rate" => "0.004",
        "rating_start_date" => "2020-01-01",
        "sms_rate" => "0.001",
        "voice_rate" => "0.0025"
      }

      assert Attrs.build(carrier_rates) == {:error, "missing required keys"}
    end

    test "when `direction` key is missing" do
      carrier_rates = %{
        "carrier_name" => "Carrier B",
        "mms_rate" => "0.004",
        "rating_start_date" => "2020-01-01",
        "sms_rate" => "0.001",
        "voice_rate" => "0.0025"
      }

      assert Attrs.build(carrier_rates) == {:error, "missing required keys"}
    end

    test "when `rating_start_date` key is missing" do
      carrier_rates = %{
        "carrier_name" => "Carrier B",
        "direction" => "OUTBOUND",
        "mms_rate" => "0.004",
        "sms_rate" => "0.001",
        "voice_rate" => "0.0025"
      }

      assert Attrs.build(carrier_rates) == {:error, "missing required keys"}
    end

    test "when one of the attrs of a list has a missing required field" do
      carrier_rates = [
        %{
          "carrier_name" => "Carrier B",
          "direction" => "OUTBOUND",
          "mms_rate" => "0.004",
          "rating_start_date" => "2020-01-01",
          "sms_rate" => "0.001",
          "voice_rate" => "0.0025"
        },
        %{
          "direction" => "OUTBOUND",
          "mms_rate" => "0.004",
          "rating_start_date" => "2020-01-01",
          "sms_rate" => "0.001",
          "voice_rate" => "0.003"
        }
      ]

      assert Attrs.build(carrier_rates) == {:error, "missing required keys"}
    end

    test "when there are no rate keys" do
      carrier_rates = %{
        "carrier_name" => "Carrier B",
        "direction" => "OUTBOUND",
        "rating_start_date" => "2020-01-01"
      }

      assert Attrs.build(carrier_rates) == {:error, "missing rate keys"}
    end

    test "when one of the attrs of a list has no rate keys" do
      carrier_rates = [
        %{
          "carrier_name" => "Carrier B",
          "direction" => "OUTBOUND",
          "mms_rate" => "0.004",
          "rating_start_date" => "2020-01-01",
          "sms_rate" => "0.001",
          "voice_rate" => "0.0025"
        },
        %{
          "carrier_name" => "Carrier A",
          "direction" => "OUTBOUND",
          "rating_start_date" => "2020-01-01"
        }
      ]

      assert Attrs.build(carrier_rates) == {:error, "missing rate keys"}
    end

    test "when map has invalid key" do
      carrier_rates = %{
        "carrier_name" => "Carrier B",
        "direction" => "OUTBOUND",
        "mms_rate" => "0.004",
        "rating_start_date" => "2020-01-01",
        "sms_rate" => "0.001",
        "voice_rate" => "0.0025",
        "invalid_key" => "value"
      }

      assert Attrs.build(carrier_rates) == {:error, "invalid key"}
    end
  end
end
