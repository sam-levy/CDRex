defmodule CDRex.ClientFeesTest do
  use CDRex.DataCase, async: true

  alias CDRex.ClientFees
  alias CDRex.ClientFees.ClientFee
  alias CDRex.FileHashes
  alias CDRex.FileHashes.FileHash

  describe "list_by_client_code/1" do
    test "returns a list ordered by `start_date` when a list of carrier client codes are provided" do
      insert(:client_fee, client_code: "RAB11", start_date: ~D[2020-06-01])
      insert(:client_fee, client_code: "RAB11", start_date: ~D[2020-01-01])

      insert(:client_fee, client_code: "LIB25", start_date: ~D[2020-06-01])
      insert(:client_fee, client_code: "LIB25", start_date: ~D[2020-01-01])

      _to_ignore = insert(:client_fee, client_code: "BIZ00", start_date: ~D[2020-01-01])

      assert [
               %ClientFee{client_code: "LIB25", start_date: ~D[2020-01-01]},
               %ClientFee{client_code: "RAB11", start_date: ~D[2020-01-01]},
               %ClientFee{client_code: "LIB25", start_date: ~D[2020-06-01]},
               %ClientFee{client_code: "RAB11", start_date: ~D[2020-06-01]}
             ] = ClientFees.list_by_client_code(["LIB25", "RAB11"])
    end

    test "when there is no carrier rate for the carrier name" do
      insert_list(2, :client_fee, client_code: "LIB25")

      assert ClientFees.list_by_client_code(["RAB11"]) == []
    end
  end

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

      {:ok, file_hash} = FileHashes.hash_file(csv_file_path)

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
               inserted_at: mms.inserted_at,
               client_code: "LIB25",
               direction: :outbound,
               fee: 0.03,
               service: :mms,
               start_date: ~D[2020-01-01]
             )

      assert Repo.get_by(ClientFee,
               id: sms.id,
               inserted_at: sms.inserted_at,
               client_code: "LIB25",
               direction: :outbound,
               fee: 0.02,
               service: :sms,
               start_date: ~D[2020-01-01]
             )

      assert Repo.get_by(ClientFee,
               id: voice.id,
               inserted_at: voice.inserted_at,
               client_code: "LIB25",
               direction: :outbound,
               fee: 0.04,
               service: :voice,
               start_date: ~D[2020-01-01]
             )

      {:ok, file_hash} = FileHashes.hash_file(csv_file_path)

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

      {:ok, file_hash} = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end

    test "malformed csv file" do
      csv_file_path = "test/support/assets/malformed_less_values.csv"

      assert ClientFees.create_from_csv(csv_file_path) == {:error, "malformed csv file"}

      {:ok, file_hash} = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end

    test "empty csv file" do
      csv_file_path = "test/support/assets/empty.csv"

      assert ClientFees.create_from_csv(csv_file_path) == {:error, "empty file"}

      {:ok, file_hash} = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end

    test "file not found" do
      csv_file_path = "test/support/assets/inexistent.csv"

      assert ClientFees.create_from_csv(csv_file_path) == {:error, "file not found"}
    end
  end
end
