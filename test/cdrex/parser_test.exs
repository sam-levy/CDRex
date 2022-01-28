defmodule CDRex.ParserTest do
  use CDRex.DataCase, async: true

  alias CDRex.Parser

  describe "parse_csv_with_headers/1" do
    test "parses a csv file" do
      csv_file_path = "test/support/assets/buy_rates.csv"

      assert Parser.parse_csv_with_headers(csv_file_path) ==
               {:ok,
                [
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
                ]}
    end

    test "when a line has less values than the header" do
      csv_file_path = "test/support/assets/malformed_less_values.csv"

      assert Parser.parse_csv_with_headers(csv_file_path) == {:error, "malformed csv file"}
    end

    test "when a line has more values than the header" do
      csv_file_path = "test/support/assets/malformed_more_values.csv"

      assert Parser.parse_csv_with_headers(csv_file_path) == {:error, "malformed csv file"}
    end

    test "empty file" do
      csv_file_path = "test/support/assets/empty.csv"

      assert Parser.parse_csv_with_headers(csv_file_path) == {:error, "empty file"}
    end

    test "file with headers only" do
      csv_file_path = "test/support/assets/headers_only.csv"

      assert Parser.parse_csv_with_headers(csv_file_path) == {:error, "empty file"}
    end
  end
end
