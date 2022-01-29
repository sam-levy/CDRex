defmodule CDRex.CarrierRatesTest do
  use CDRex.DataCase, async: true

  alias CDRex.CarrierRates
  alias CDRex.CarrierRates.CarrierRate
  alias CDRex.FileHashes
  alias CDRex.FileHashes.FileHash

  describe "list_by_carrier_name/1" do
    test "returns a list ordered by `start_date`" do
      insert(:carrier_rate, carrier_name: "Carrier B", start_date: ~D[2020-06-01])
      insert(:carrier_rate, carrier_name: "Carrier B", start_date: ~D[2020-01-01])

      insert(:carrier_rate, carrier_name: "Carrier A", start_date: ~D[2020-06-01])
      insert(:carrier_rate, carrier_name: "Carrier A", start_date: ~D[2020-01-01])

      _to_ignore = insert(:carrier_rate, carrier_name: "Carrier C", start_date: ~D[2020-01-01])

      assert [
              %CarrierRate{carrier_name: "Carrier A", start_date: ~D[2020-01-01]},
              %CarrierRate{carrier_name: "Carrier B", start_date: ~D[2020-01-01]},
              %CarrierRate{carrier_name: "Carrier A", start_date: ~D[2020-06-01]},
              %CarrierRate{carrier_name: "Carrier B", start_date: ~D[2020-06-01]}
            ] = CarrierRates.list_by_carrier_name(["Carrier A", "Carrier B"])
    end

    test "when there is no carrier rate for the carrier name" do
      insert_list(2, :carrier_rate, carrier_name: "Carrier A")

      assert CarrierRates.list_by_carrier_name(["Carrier B"]) == []
    end
  end

  describe "create_from_csv/1" do
    test "creates carrier rates from a CSV file and add insert file hash" do
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

      file_hash = FileHashes.hash_file(csv_file_path)

      assert %FileHash{hash: ^file_hash} = Repo.get_by(FileHash, hash: file_hash)
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
               inserted_at: mms.inserted_at,
               carrier_name: "Carrier B",
               direction: :outbound,
               rate: 0.004,
               service: :mms,
               start_date: ~D[2020-01-01]
             )

      assert Repo.get_by(CarrierRate,
               id: sms.id,
               inserted_at: sms.inserted_at,
               carrier_name: "Carrier B",
               direction: :outbound,
               rate: 0.001,
               service: :sms,
               start_date: ~D[2020-01-01]
             )

      assert Repo.get_by(CarrierRate,
               id: voice.id,
               inserted_at: voice.inserted_at,
               carrier_name: "Carrier B",
               direction: :outbound,
               rate: 0.0025,
               service: :voice,
               start_date: ~D[2020-01-01]
             )

      file_hash = FileHashes.hash_file(csv_file_path)

      assert %FileHash{hash: ^file_hash} = Repo.get_by(FileHash, hash: file_hash)
    end

    test "return error when file has already been imported" do
      csv_file_path = "test/support/assets/buy_rates.csv"

      assert {:ok, _carrier_rates} = CarrierRates.create_from_csv(csv_file_path)

      assert CarrierRates.create_from_csv(csv_file_path) ==
               {:error, "the file has already been imported"}
    end

    test "returns changeset errors when csv contains invalid values" do
      csv_file_path = "test/support/assets/buy_rates_invalid_values.csv"

      assert {:error, changeset} = CarrierRates.create_from_csv(csv_file_path)

      assert errors_on(changeset) == %{
               direction: ["is invalid"],
               start_date: ["is invalid"],
               rate: ["is invalid"]
             }

      file_hash = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end

    test "malformed csv file" do
      csv_file_path = "test/support/assets/malformed_less_values.csv"

      assert CarrierRates.create_from_csv(csv_file_path) == {:error, "malformed csv file"}

      file_hash = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end

    test "empty csv file" do
      csv_file_path = "test/support/assets/empty.csv"

      assert CarrierRates.create_from_csv(csv_file_path) == {:error, "empty file"}

      file_hash = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end
  end
end
