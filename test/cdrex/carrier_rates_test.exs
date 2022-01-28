defmodule CDRex.CarrierRatesTest do
  use CDRex.DataCase, async: true

  alias CDRex.CarrierRates
  alias CDRex.CarrierRates.CarrierRate

  describe "create_from_csv/1" do
    test "creates carrier rates from a CSV file" do
      csv_file_path = "test/support/assets/buy_rates.csv"

      assert {:ok,
              [
                %CarrierRate{
                  carrier_name: "Carrier B",
                  direction: :outbound,
                  rate: 0.004,
                  service: :mms,
                  start_date: ~D[2020-01-01]
                },
                %CarrierRate{
                  carrier_name: "Carrier B",
                  direction: :outbound,
                  rate: 0.001,
                  service: :sms,
                  start_date: ~D[2020-01-01]
                },
                %CarrierRate{
                  carrier_name: "Carrier B",
                  direction: :outbound,
                  rate: 0.0025,
                  service: :voice,
                  start_date: ~D[2020-01-01]
                },
                %CarrierRate{
                  carrier_name: "Carrier A",
                  direction: :outbound,
                  rate: 0.004,
                  service: :mms,
                  start_date: ~D[2020-01-01]
                },
                %CarrierRate{
                  carrier_name: "Carrier A",
                  direction: :outbound,
                  rate: 0.001,
                  service: :sms,
                  start_date: ~D[2020-01-01]
                },
                %CarrierRate{
                  carrier_name: "Carrier A",
                  direction: :outbound,
                  rate: 0.003,
                  service: :voice,
                  start_date: ~D[2020-01-01]
                }
              ]} = CarrierRates.create_from_csv(csv_file_path)
    end

    test "updates existing carrier rates" do
      mms =
        insert(:carrier_rate,
          carrier_name: "Carrier B",
          direction: :outbound,
          rate: 0.1,
          service: :mms,
          start_date: ~D[2020-01-01]
        )

      sms =
        insert(:carrier_rate,
          carrier_name: "Carrier B",
          direction: :outbound,
          rate: 0.1,
          service: :sms,
          start_date: ~D[2020-01-01]
        )

      voice =
        insert(:carrier_rate,
          carrier_name: "Carrier B",
          direction: :outbound,
          rate: 0.1,
          service: :voice,
          start_date: ~D[2020-01-01]
        )

      csv_file_path = "test/support/assets/buy_rates.csv"

      assert {:ok,
              [
                %CarrierRate{
                  carrier_name: "Carrier B",
                  direction: :outbound,
                  rate: 0.004,
                  service: :mms,
                  start_date: ~D[2020-01-01]
                },
                %CarrierRate{
                  carrier_name: "Carrier B",
                  direction: :outbound,
                  rate: 0.001,
                  service: :sms,
                  start_date: ~D[2020-01-01]
                },
                %CarrierRate{
                  carrier_name: "Carrier B",
                  direction: :outbound,
                  rate: 0.0025,
                  service: :voice,
                  start_date: ~D[2020-01-01]
                },
                %CarrierRate{
                  carrier_name: "Carrier A",
                  direction: :outbound,
                  rate: 0.004,
                  service: :mms,
                  start_date: ~D[2020-01-01]
                },
                %CarrierRate{
                  carrier_name: "Carrier A",
                  direction: :outbound,
                  rate: 0.001,
                  service: :sms,
                  start_date: ~D[2020-01-01]
                },
                %CarrierRate{
                  carrier_name: "Carrier A",
                  direction: :outbound,
                  rate: 0.003,
                  service: :voice,
                  start_date: ~D[2020-01-01]
                }
              ]} = CarrierRates.create_from_csv(csv_file_path)

      assert Repo.aggregate(CarrierRate, :count) == 6

      assert Repo.get_by(CarrierRate,
               id: mms.id,
               carrier_name: "Carrier B",
               direction: :outbound,
               rate: 0.004,
               service: :mms,
               start_date: ~D[2020-01-01]
             )

      assert Repo.get_by(CarrierRate,
               id: sms.id,
               carrier_name: "Carrier B",
               direction: :outbound,
               rate: 0.001,
               service: :sms,
               start_date: ~D[2020-01-01]
             )

      assert Repo.get_by(CarrierRate,
               id: voice.id,
               carrier_name: "Carrier B",
               direction: :outbound,
               rate: 0.0025,
               service: :voice,
               start_date: ~D[2020-01-01]
             )
    end

    test "returns changeset errors when csv contains invalid values" do
      csv_file_path = "test/support/assets/buy_rates_invalid_values.csv"

      assert {:error, changeset} = CarrierRates.create_from_csv(csv_file_path)

      assert errors_on(changeset) == %{
        direction: ["is invalid"],
        start_date: ["is invalid"],
        rate: ["is invalid"]
      }
    end

    test "malformed csv file" do
      csv_file_path = "test/support/assets/malformed_less_values.csv"

      assert CarrierRates.create_from_csv(csv_file_path) == {:error, "malformed csv file"}
    end

    test "empty csv file" do
      csv_file_path = "test/support/assets/empty.csv"

      assert CarrierRates.create_from_csv(csv_file_path) == {:error, "empty file"}
    end
  end
end
