defmodule CDRex.ClientFeesTest do
  use CDRex.DataCase, async: true

  alias CDRex.ClientFees
  alias CDRex.ClientFees.ClientFee
  alias CDRex.FileHashes
  alias CDRex.FileHashes.FileHash

  describe "create_from_csv/1" do
    test "creates client fees from a CSV file and add insert file hash" do
      csv_file_path = "test/support/assets/sell_rates.csv"

      assert {:ok,
              [
                %ClientFee{
                  client_code: "LIB25",
                  direction: :outbound,
                  fee: 0.03,
                  service: :mms,
                  start_date: ~D[2020-01-01]
                },
                %ClientFee{
                  client_code: "LIB25",
                  direction: :outbound,
                  fee: 0.02,
                  service: :sms,
                  start_date: ~D[2020-01-01]
                },
                %ClientFee{
                  client_code: "LIB25",
                  direction: :outbound,
                  fee: 0.04,
                  service: :voice,
                  start_date: ~D[2020-01-01]
                },
                %ClientFee{
                  client_code: "RAB11",
                  direction: :outbound,
                  fee: 0.01,
                  service: :mms,
                  start_date: ~D[2020-01-01]
                },
                %ClientFee{
                  client_code: "RAB11",
                  direction: :outbound,
                  fee: 0.01,
                  service: :sms,
                  start_date: ~D[2020-01-01]
                },
                %ClientFee{
                  client_code: "RAB11",
                  direction: :outbound,
                  fee: 0.01,
                  service: :voice,
                  start_date: ~D[2020-01-01]
                }
              ]} = ClientFees.create_from_csv(csv_file_path)

      file_hash = FileHashes.hash_file(csv_file_path)

      assert %FileHash{hash: ^file_hash} = Repo.get_by(FileHash, hash: file_hash)
    end

    test "updates existing client fees" do
      mms =
        insert(:client_fee,
          client_code: "LIB25",
          direction: :outbound,
          fee: 0.1,
          service: :mms,
          start_date: ~D[2020-01-01]
        )

      sms =
        insert(:client_fee,
          client_code: "LIB25",
          direction: :outbound,
          fee: 0.1,
          service: :sms,
          start_date: ~D[2020-01-01]
        )

      voice =
        insert(:client_fee,
          client_code: "LIB25",
          direction: :outbound,
          fee: 0.1,
          service: :voice,
          start_date: ~D[2020-01-01]
        )

      csv_file_path = "test/support/assets/sell_rates.csv"

      assert {:ok,
              [
                %ClientFee{
                  client_code: "LIB25",
                  direction: :outbound,
                  fee: 0.03,
                  service: :mms,
                  start_date: ~D[2020-01-01]
                },
                %ClientFee{
                  client_code: "LIB25",
                  direction: :outbound,
                  fee: 0.02,
                  service: :sms,
                  start_date: ~D[2020-01-01]
                },
                %ClientFee{
                  client_code: "LIB25",
                  direction: :outbound,
                  fee: 0.04,
                  service: :voice,
                  start_date: ~D[2020-01-01]
                },
                %ClientFee{
                  client_code: "RAB11",
                  direction: :outbound,
                  fee: 0.01,
                  service: :mms,
                  start_date: ~D[2020-01-01]
                },
                %ClientFee{
                  client_code: "RAB11",
                  direction: :outbound,
                  fee: 0.01,
                  service: :sms,
                  start_date: ~D[2020-01-01]
                },
                %ClientFee{
                  client_code: "RAB11",
                  direction: :outbound,
                  fee: 0.01,
                  service: :voice,
                  start_date: ~D[2020-01-01]
                }
              ]} = ClientFees.create_from_csv(csv_file_path)

      assert Repo.aggregate(ClientFee, :count) == 6

      assert Repo.get_by(ClientFee,
               id: mms.id,
               client_code: "LIB25",
               direction: :outbound,
               fee: 0.03,
               service: :mms,
               start_date: ~D[2020-01-01]
             )

      assert Repo.get_by(ClientFee,
               id: sms.id,
               client_code: "LIB25",
               direction: :outbound,
               fee: 0.02,
               service: :sms,
               start_date: ~D[2020-01-01]
             )

      assert Repo.get_by(ClientFee,
               id: voice.id,
               client_code: "LIB25",
               direction: :outbound,
               fee: 0.04,
               service: :voice,
               start_date: ~D[2020-01-01]
             )

      file_hash = FileHashes.hash_file(csv_file_path)

      assert %FileHash{hash: ^file_hash} = Repo.get_by(FileHash, hash: file_hash)
    end

    test "return error when file has already been imported" do
      csv_file_path = "test/support/assets/sell_rates.csv"

      assert {:ok, _client_fees} = ClientFees.create_from_csv(csv_file_path)

      assert ClientFees.create_from_csv(csv_file_path) ==
               {:error, "the file has already been imported"}
    end

    test "returns changeset errors when csv contains invalid values" do
      csv_file_path = "test/support/assets/sell_rates_invalid_values.csv"

      assert {:error, changeset} = ClientFees.create_from_csv(csv_file_path)

      assert errors_on(changeset) == %{
               direction: ["is invalid"]
             }

      file_hash = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end

    test "malformed csv file" do
      csv_file_path = "test/support/assets/malformed_less_values.csv"

      assert ClientFees.create_from_csv(csv_file_path) == {:error, "malformed csv file"}

      file_hash = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end

    test "empty csv file" do
      csv_file_path = "test/support/assets/empty.csv"

      assert ClientFees.create_from_csv(csv_file_path) == {:error, "empty file"}

      file_hash = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end
  end
end
