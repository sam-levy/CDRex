defmodule CDRex.ClientFees.AttrsTest  do
  use CDRex.DataCase, async: true

  alias CDRex.ClientFees.Attrs

  describe "build/1" do
    test "builds a list of Attrs structs from a valid map" do
      client_fees = %{
        "client_code" => "LIB25",
        "direction" => "OUTBOUND",
        "mms_fee" => "0.004",
        "price_start_date" => "2020-01-01",
        "sms_fee" => "0.001",
        "voice_fee" => "0.0025"
      }

      assert Attrs.build(client_fees) ==
               {:ok,
                [
                  %Attrs{
                    client_code: "LIB25",
                    direction: "outbound",
                    fee: "0.0025",
                    service: :voice,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    client_code: "LIB25",
                    direction: "outbound",
                    fee: "0.001",
                    service: :sms,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    client_code: "LIB25",
                    direction: "outbound",
                    fee: "0.004",
                    service: :mms,
                    start_date: "2020-01-01"
                  }
                ]}
    end

    test "builds a list of Attrs structs from a list of valid maps" do
      client_fees = [
        %{
          "client_code" => "LIB25",
          "direction" => "OUTBOUND",
          "mms_fee" => "0.004",
          "price_start_date" => "2020-01-01",
          "sms_fee" => "0.001",
          "voice_fee" => "0.0025"
        },
        %{
          "client_code" => "RAB11",
          "direction" => "OUTBOUND",
          "mms_fee" => "0.004",
          "price_start_date" => "2020-01-01",
          "sms_fee" => "0.001",
          "voice_fee" => "0.003"
        }
      ]

      assert Attrs.build(client_fees) ==
               {:ok,
                [
                  %Attrs{
                    client_code: "RAB11",
                    direction: "outbound",
                    fee: "0.003",
                    service: :voice,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    client_code: "RAB11",
                    direction: "outbound",
                    fee: "0.001",
                    service: :sms,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    client_code: "RAB11",
                    direction: "outbound",
                    fee: "0.004",
                    service: :mms,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    client_code: "LIB25",
                    direction: "outbound",
                    fee: "0.0025",
                    service: :voice,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    client_code: "LIB25",
                    direction: "outbound",
                    fee: "0.001",
                    service: :sms,
                    start_date: "2020-01-01"
                  },
                  %Attrs{
                    client_code: "LIB25",
                    direction: "outbound",
                    fee: "0.004",
                    service: :mms,
                    start_date: "2020-01-01"
                  }
                ]}
    end

    test "builds a list of Attrs structs from a parcial valid map" do
      client_fees = %{
        "client_code" => "LIB25",
        "direction" => "OUTBOUND",
        "mms_fee" => "0.004",
        "price_start_date" => "2020-01-01"
      }

      assert Attrs.build(client_fees) ==
               {:ok,
                [
                  %Attrs{
                    client_code: "LIB25",
                    direction: "outbound",
                    fee: "0.004",
                    service: :mms,
                    start_date: "2020-01-01"
                  }
                ]}
    end

    test "when `client_code` key is missing" do
      client_fees = %{
        "direction" => "OUTBOUND",
        "mms_fee" => "0.004",
        "price_start_date" => "2020-01-01",
        "sms_fee" => "0.001",
        "voice_fee" => "0.0025"
      }

      assert Attrs.build(client_fees) == {:error, "missing required keys"}
    end

    test "when `direction` key is missing" do
      client_fees = %{
        "client_code" => "LIB25",
        "mms_fee" => "0.004",
        "price_start_date" => "2020-01-01",
        "sms_fee" => "0.001",
        "voice_fee" => "0.0025"
      }

      assert Attrs.build(client_fees) == {:error, "missing required keys"}
    end

    test "when `price_start_date` key is missing" do
      client_fees = %{
        "client_code" => "LIB25",
        "direction" => "OUTBOUND",
        "mms_fee" => "0.004",
        "sms_fee" => "0.001",
        "voice_fee" => "0.0025"
      }

      assert Attrs.build(client_fees) == {:error, "missing required keys"}
    end

    test "when one of the attrs of a list has a missing required field" do
      client_fees = [
        %{
          "client_code" => "LIB25",
          "direction" => "OUTBOUND",
          "mms_fee" => "0.004",
          "price_start_date" => "2020-01-01",
          "sms_fee" => "0.001",
          "voice_fee" => "0.0025"
        },
        %{
          "direction" => "OUTBOUND",
          "mms_fee" => "0.004",
          "price_start_date" => "2020-01-01",
          "sms_fee" => "0.001",
          "voice_fee" => "0.003"
        }
      ]

      assert Attrs.build(client_fees) == {:error, "missing required keys"}
    end

    test "when there are no fee keys" do
      client_fees = %{
        "client_code" => "LIB25",
        "direction" => "OUTBOUND",
        "price_start_date" => "2020-01-01"
      }

      assert Attrs.build(client_fees) == {:error, "missing fee keys"}
    end

    test "when one of the attrs of a list has no fee keys" do
      client_fees = [
        %{
          "client_code" => "LIB25",
          "direction" => "OUTBOUND",
          "mms_fee" => "0.004",
          "price_start_date" => "2020-01-01",
          "sms_fee" => "0.001",
          "voice_fee" => "0.0025"
        },
        %{
          "client_code" => "RAB11",
          "direction" => "OUTBOUND",
          "price_start_date" => "2020-01-01"
        }
      ]

      assert Attrs.build(client_fees) == {:error, "missing fee keys"}
    end

    test "when map has invalid key" do
      client_fees = %{
        "client_code" => "LIB25",
        "direction" => "OUTBOUND",
        "mms_fee" => "0.004",
        "price_start_date" => "2020-01-01",
        "sms_fee" => "0.001",
        "voice_fee" => "0.0025",
        "invalid_key" => "value"
      }

      assert Attrs.build(client_fees) == {:error, "invalid key"}
    end
  end
end
