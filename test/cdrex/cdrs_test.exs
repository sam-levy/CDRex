defmodule CDRex.CDRsTest do
  use CDRex.DataCase, async: true

  alias CDRex.CDRs
  alias CDRex.CDRs.CDR
  alias CDRex.FileHashes
  alias CDRex.FileHashes.FileHash

  describe "create_from_csv/1" do
    test "creates cdrs from a CSV file and add insert file hash" do
      csv_file_path = "test/support/assets/cdrs.csv"

      assert {:ok,
              [
                %CDR{
                  carrier_name: "Carrier B",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "17148943322",
                  direction: :inbound,
                  number_of_units: 10,
                  service: :voice,
                  source_number: "16197558541",
                  success: true,
                  timestamp: ~N[2020-12-31 23:59:11]
                },
                %CDR{
                  carrier_name: "Carrier A",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "18014848755",
                  direction: :outbound,
                  number_of_units: 96,
                  service: :voice,
                  source_number: "17083986237",
                  success: true,
                  timestamp: ~N[2021-01-01 00:05:26]
                },
                %CDR{
                  carrier_name: "Carrier B",
                  client_code: "RAB11",
                  client_name: "Biznode",
                  destination_number: "12703665756",
                  direction: :outbound,
                  number_of_units: 49,
                  service: :voice,
                  source_number: "16013167018",
                  success: true,
                  timestamp: ~N[2021-01-01 00:05:49]
                },
                %CDR{
                  carrier_name: "Carrier B",
                  client_code: "RAB11",
                  client_name: "Biznode",
                  destination_number: "12705575114",
                  direction: :outbound,
                  number_of_units: 41,
                  service: :voice,
                  source_number: "19803395703",
                  success: false,
                  timestamp: ~N[2021-01-01 00:07:01]
                },
                %CDR{
                  carrier_name: "Carrier B",
                  client_code: "LIB25",
                  client_name: "Lib Group",
                  destination_number: "12705575114",
                  direction: :outbound,
                  number_of_units: 10,
                  service: :voice,
                  source_number: "16619525945",
                  success: true,
                  timestamp: ~N[2021-01-01 00:02:29]
                },
                %CDR{
                  carrier_name: "Carrier C",
                  client_code: "LIB25",
                  client_name: "Lib Group",
                  destination_number: "17066135090",
                  direction: :outbound,
                  number_of_units: 39,
                  service: :voice,
                  source_number: "12159538568",
                  success: true,
                  timestamp: ~N[2021-01-01 00:01:03]
                }
              ]} = CDRs.create_from_csv(csv_file_path)

      file_hash = FileHashes.hash_file(csv_file_path)

      assert %FileHash{hash: ^file_hash} = Repo.get_by(FileHash, hash: file_hash)
    end

    test "updates existing cdrs" do
      existing_cdr =
        insert(:cdr,
          carrier_name: "Carrier B",
          client_code: "BIZ00",
          client_name: "Biznode",
          destination_number: "17148943322",
          direction: :inbound,
          number_of_units: 20,
          service: :voice,
          source_number: "16197558541",
          success: true,
          timestamp: ~N[2020-12-31 23:59:11]
        )

      csv_file_path = "test/support/assets/cdrs.csv"

      assert {:ok,
              [
                %CDR{
                  carrier_name: "Carrier B",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "17148943322",
                  direction: :inbound,
                  number_of_units: 10,
                  service: :voice,
                  source_number: "16197558541",
                  success: true,
                  timestamp: ~N[2020-12-31 23:59:11]
                },
                %CDR{
                  carrier_name: "Carrier A",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "18014848755",
                  direction: :outbound,
                  number_of_units: 96,
                  service: :voice,
                  source_number: "17083986237",
                  success: true,
                  timestamp: ~N[2021-01-01 00:05:26]
                },
                %CDR{
                  carrier_name: "Carrier B",
                  client_code: "RAB11",
                  client_name: "Biznode",
                  destination_number: "12703665756",
                  direction: :outbound,
                  number_of_units: 49,
                  service: :voice,
                  source_number: "16013167018",
                  success: true,
                  timestamp: ~N[2021-01-01 00:05:49]
                },
                %CDR{
                  carrier_name: "Carrier B",
                  client_code: "RAB11",
                  client_name: "Biznode",
                  destination_number: "12705575114",
                  direction: :outbound,
                  number_of_units: 41,
                  service: :voice,
                  source_number: "19803395703",
                  success: false,
                  timestamp: ~N[2021-01-01 00:07:01]
                },
                %CDR{
                  carrier_name: "Carrier B",
                  client_code: "LIB25",
                  client_name: "Lib Group",
                  destination_number: "12705575114",
                  direction: :outbound,
                  number_of_units: 10,
                  service: :voice,
                  source_number: "16619525945",
                  success: true,
                  timestamp: ~N[2021-01-01 00:02:29]
                },
                %CDR{
                  carrier_name: "Carrier C",
                  client_code: "LIB25",
                  client_name: "Lib Group",
                  destination_number: "17066135090",
                  direction: :outbound,
                  number_of_units: 39,
                  service: :voice,
                  source_number: "12159538568",
                  success: true,
                  timestamp: ~N[2021-01-01 00:01:03]
                }
              ]} = CDRs.create_from_csv(csv_file_path)

      assert Repo.aggregate(CDR, :count) == 6

      assert Repo.get_by(CDR,
               id: existing_cdr.id,
               inserted_at: existing_cdr.inserted_at,
               carrier_name: "Carrier B",
               client_code: "BIZ00",
               client_name: "Biznode",
               destination_number: "17148943322",
               direction: :inbound,
               number_of_units: 10,
               service: :voice,
               source_number: "16197558541",
               success: true,
               timestamp: ~N[2020-12-31 23:59:11]
             )

      file_hash = FileHashes.hash_file(csv_file_path)

      assert %FileHash{hash: ^file_hash} = Repo.get_by(FileHash, hash: file_hash)
    end

    test "return error when file has already been imported" do
      csv_file_path = "test/support/assets/cdrs.csv"

      assert {:ok, _cdrs} = CDRs.create_from_csv(csv_file_path)

      assert CDRs.create_from_csv(csv_file_path) ==
               {:error, "the file has already been imported"}
    end

    test "returns changeset errors when csv contains invalid values" do
      csv_file_path = "test/support/assets/cdrs_invalid_values.csv"

      assert {:error, changeset} = CDRs.create_from_csv(csv_file_path)

      assert errors_on(changeset) == %{
               success: ["is invalid"],
               service: ["is invalid"]
             }

      file_hash = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end

    test "returns error when timestamp format is invalid" do
      csv_file_path = "test/support/assets/cdrs_invalid_timestamp.csv"

      assert CDRs.create_from_csv(csv_file_path) == {:error, "invalid timestamp format"}

      file_hash = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end

    test "malformed csv file" do
      csv_file_path = "test/support/assets/malformed_less_values.csv"

      assert CDRs.create_from_csv(csv_file_path) == {:error, "malformed csv file"}

      file_hash = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end

    test "empty csv file" do
      csv_file_path = "test/support/assets/empty.csv"

      assert CDRs.create_from_csv(csv_file_path) == {:error, "empty file"}

      file_hash = FileHashes.hash_file(csv_file_path)

      refute Repo.get_by(FileHash, hash: file_hash)
    end
  end
end
