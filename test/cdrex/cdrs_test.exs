defmodule CDRex.CDRsTest do
  use CDRex.DataCase, async: true

  alias CDRex.CDRs
  alias CDRex.CDRs.CDR
  alias CDRex.FileHashes
  alias CDRex.FileHashes.FileHash

  describe "create/2" do
    test "creates a CDR from attrs" do
      insert(:carrier_rate,
        carrier_name: "Carrier B",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        rate: 0.001
      )

      insert(:client_fee,
        client_code: "BIZ00",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        fee: 0.01
      )

      attrs = %{
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

      assert {:ok,
              [
                %CDR{
                  id: id,
                  amount: 0.11,
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
                }
              ]} = CDRs.create(attrs)

      assert Repo.get_by(CDR,
               id: id,
               amount: 0.11,
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
    end

    test "creates CDRs from attrs list" do
      insert(:carrier_rate,
        carrier_name: "Carrier B",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        rate: 0.001
      )

      insert(:client_fee,
        client_code: "BIZ00",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        fee: 0.01
      )

      attrs = [
        %{
          carrier_name: "Carrier B",
          client_code: "BIZ00",
          client_name: "Biznode",
          destination_number: "18014848755",
          direction: "inbound",
          number_of_units: "96",
          service: "voice",
          source_number: "17083986237",
          success: "true",
          timestamp: ~N[2020-12-30 22:00:00]
        },
        %{
          carrier_name: "Carrier B",
          client_code: "BIZ00",
          client_name: "Biznode",
          destination_number: "17148943322",
          direction: "inbound",
          number_of_units: "10",
          service: "voice",
          source_number: "16197558541",
          success: "true",
          timestamp: ~N[2020-12-31 23:59:59]
        }
      ]

      assert {:ok,
              [
                %CDR{
                  id: id_1,
                  amount: 0.11,
                  carrier_name: "Carrier B",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "17148943322",
                  direction: :inbound,
                  number_of_units: 10,
                  service: :voice,
                  source_number: "16197558541",
                  success: true,
                  timestamp: ~N[2020-12-31 23:59:59]
                },
                %CDR{
                  id: id_2,
                  amount: 1.056,
                  carrier_name: "Carrier B",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "18014848755",
                  direction: :inbound,
                  number_of_units: 96,
                  service: :voice,
                  source_number: "17083986237",
                  success: true,
                  timestamp: ~N[2020-12-30 22:00:00]
                }
              ]} = CDRs.create(attrs)

      assert Repo.get_by(CDR,
               id: id_1,
               amount: 0.11,
               carrier_name: "Carrier B",
               client_code: "BIZ00",
               client_name: "Biznode",
               destination_number: "17148943322",
               direction: :inbound,
               number_of_units: 10,
               service: :voice,
               source_number: "16197558541",
               success: true,
               timestamp: ~N[2020-12-31 23:59:59]
             )

      assert Repo.get_by(CDR,
               id: id_2,
               amount: 1.056,
               carrier_name: "Carrier B",
               client_code: "BIZ00",
               client_name: "Biznode",
               destination_number: "18014848755",
               direction: :inbound,
               number_of_units: 96,
               service: :voice,
               source_number: "17083986237",
               success: true,
               timestamp: ~N[2020-12-30 22:00:00]
             )
    end

    test "invalid attrs" do
      insert(:carrier_rate,
        carrier_name: "Carrier B",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        rate: 0.001
      )

      insert(:client_fee,
        client_code: "BIZ00",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        fee: 0.01
      )

      attrs = %{
        carrier_name: "Carrier B",
        client_code: "BIZ00",
        client_name: "Biznode",
        destination_number: "17148943322",
        direction: "INVALID",
        number_of_units: "10",
        service: "voice",
        source_number: "16197558541",
        success: "INVALID",
        timestamp: ~N[2020-12-31 23:59:11]
      }

      assert {:error, changeset} = CDRs.create(attrs)

      assert errors_on(changeset) == %{
        direction: ["is invalid"],
        success: ["is invalid"]
      }

      assert Repo.aggregate(CDR, :count) == 0
    end

    test "creates CDRs with different amounts for the same client, direction and service when timestamps are different" do
      # Carrier rates
      insert(:carrier_rate,
        carrier_name: "Carrier B",
        start_date: ~D[2020-01-01],
        service: :voice,
        direction: :inbound,
        rate: 0.001
      )

      insert(:carrier_rate,
        carrier_name: "Carrier B",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        rate: 0.002
      )

      insert(:carrier_rate,
        carrier_name: "Carrier B",
        start_date: ~D[2021-01-01],
        service: :voice,
        direction: :inbound,
        rate: 0.003
      )

      # Client fees
      insert(:client_fee,
        client_code: "BIZ00",
        start_date: ~D[2020-01-01],
        service: :voice,
        direction: :inbound,
        fee: 0.01
      )

      insert(:client_fee,
        client_code: "BIZ00",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        fee: 0.02
      )

      insert(:client_fee,
        client_code: "BIZ00",
        start_date: ~D[2021-01-01],
        service: :voice,
        direction: :inbound,
        fee: 0.03
      )

      attrs = [
        %{
          carrier_name: "Carrier B",
          client_code: "BIZ00",
          client_name: "Biznode",
          destination_number: "18014848755",
          direction: "inbound",
          number_of_units: "10",
          service: "voice",
          source_number: "17083986237",
          success: "true",
          timestamp: ~N[2020-06-01 23:00:00]
        },
        %{
          carrier_name: "Carrier B",
          client_code: "BIZ00",
          client_name: "Biznode",
          destination_number: "18014848755",
          direction: "inbound",
          number_of_units: "10",
          service: "voice",
          source_number: "17083986237",
          success: "true",
          timestamp: ~N[2021-01-01 22:00:00]
        }
      ]

      assert {:ok,
              [
                %CDR{
                  amount: 0.33,
                  carrier_name: "Carrier B",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "18014848755",
                  direction: :inbound,
                  number_of_units: 10,
                  service: :voice,
                  source_number: "17083986237",
                  success: true,
                  timestamp: ~N[2021-01-01 22:00:00]
                },
                %CDR{
                  amount: 0.22,
                  carrier_name: "Carrier B",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "18014848755",
                  direction: :inbound,
                  number_of_units: 10,
                  service: :voice,
                  source_number: "17083986237",
                  success: true,
                  timestamp: ~N[2020-06-01 23:00:00]
                }
              ]} = CDRs.create(attrs)
    end

    test "creates a CDR with `amount` zero when the attrs `success` is false" do
      insert(:carrier_rate,
        carrier_name: "Carrier B",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        rate: 0.001
      )

      insert(:client_fee,
        client_code: "BIZ00",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        fee: 0.01
      )

      attrs = %{
        carrier_name: "Carrier B",
        client_code: "BIZ00",
        client_name: "Biznode",
        destination_number: "17148943322",
        direction: "inbound",
        number_of_units: "10",
        service: "voice",
        source_number: "16197558541",
        success: "false",
        timestamp: ~N[2020-12-31 23:59:11]
      }

      assert {:ok,
              [
                %CDR{
                  amount: 0.0,
                  carrier_name: "Carrier B",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "17148943322",
                  direction: :inbound,
                  number_of_units: 10,
                  service: :voice,
                  source_number: "16197558541",
                  success: false,
                  timestamp: ~N[2020-12-31 23:59:11]
                }
              ]} = CDRs.create(attrs)
    end

    test "when there is no carrier rate for the CDR attrs" do
      _sms_carrier_rate =
        insert(:carrier_rate,
          carrier_name: "Carrier B",
          start_date: ~D[2020-06-01],
          service: :sms,
          direction: :inbound,
          rate: 0.001
        )

      insert(:client_fee,
        client_code: "BIZ00",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        fee: 0.01
      )

      # Voice CDR
      attrs = %{
        carrier_name: "Carrier B",
        client_code: "BIZ00",
        client_name: "Biznode",
        destination_number: "17148943322",
        direction: "inbound",
        number_of_units: "10",
        service: "voice",
        source_number: "16197558541",
        success: "true",
        timestamp: ~N[2020-12-31 23:59:59]
      }

      assert {:error, changeset} = CDRs.create(attrs)

      assert errors_on(changeset) == %{
               amount: ["carrier rate not found for the CDR"]
             }

      assert Repo.aggregate(CDR, :count) == 0
    end

    test "when there is no client fee for one of the CDRs attrs" do
      insert(:carrier_rate,
        carrier_name: "Carrier B",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        rate: 0.001
      )

      insert(:carrier_rate,
        carrier_name: "Carrier B",
        start_date: ~D[2020-06-01],
        service: :sms,
        direction: :inbound,
        rate: 0.001
      )

      insert(:client_fee,
        client_code: "LIB25",
        start_date: ~D[2020-06-01],
        service: :sms,
        direction: :inbound,
        fee: 0.01
      )

      insert(:client_fee,
        client_code: "BIZ00",
        start_date: ~D[2020-06-01],
        service: :sms,
        direction: :inbound,
        fee: 0.01
      )

      attrs = [
        %{
          carrier_name: "Carrier B",
          client_code: "LIB25",
          client_name: "Lib Group",
          destination_number: "18014848755",
          direction: "inbound",
          number_of_units: "96",
          service: "sms",
          source_number: "17083986237",
          success: "true",
          timestamp: ~N[2020-12-31 23:59:59]
        },
        # CDR attrs with inexistent service client fee
        %{
          carrier_name: "Carrier B",
          client_code: "BIZ00",
          client_name: "Biznode",
          destination_number: "17148943322",
          direction: "inbound",
          number_of_units: "10",
          service: "voice",
          source_number: "16197558541",
          success: "true",
          timestamp: ~N[2020-12-31 23:59:59]
        }
      ]

      assert {:error, %{changes: %{client_code: "BIZ00"}} = changeset} = CDRs.create(attrs)

      assert errors_on(changeset) == %{
               amount: ["client fee not found for the CDR"]
             }

      assert Repo.aggregate(CDR, :count) == 0
    end

    test "when there is no carrier rate with `start_date` before the CDR attrs `timestamp`" do
      insert(:carrier_rate,
        carrier_name: "Carrier B",
        start_date: ~D[2021-01-01],
        service: :voice,
        direction: :inbound,
        rate: 0.001
      )

      insert(:carrier_rate,
        carrier_name: "Carrier B",
        start_date: ~D[2021-06-01],
        service: :voice,
        direction: :inbound,
        rate: 0.002
      )

      insert(:client_fee,
        client_code: "BIZ00",
        start_date: ~D[2020-12-31],
        service: :voice,
        direction: :inbound,
        fee: 0.01
      )

      attrs = %{
        carrier_name: "Carrier B",
        client_code: "BIZ00",
        client_name: "Biznode",
        destination_number: "17148943322",
        direction: "inbound",
        number_of_units: "10",
        service: "voice",
        source_number: "16197558541",
        success: "true",
        timestamp: ~N[2020-12-31 23:59:59]
      }

      assert {:error, changeset} = CDRs.create(attrs)

      assert errors_on(changeset) == %{
               amount: ["carrier rate not found for the CDR timestamp"]
             }

      assert Repo.aggregate(CDR, :count) == 0
    end

    test "when there is no client fee with `start_date` before one of the CDRs attrs `timestamp`" do
      insert(:carrier_rate,
        carrier_name: "Carrier B",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        rate: 0.001
      )

      insert(:client_fee,
        client_code: "LIB25",
        start_date: ~D[2020-06-01],
        service: :voice,
        direction: :inbound,
        fee: 0.01
      )

      insert(:client_fee,
        client_code: "BIZ00",
        start_date: ~D[2021-01-01],
        service: :voice,
        direction: :inbound,
        fee: 0.01
      )

      insert(:client_fee,
        client_code: "BIZ00",
        start_date: ~D[2021-06-01],
        service: :voice,
        direction: :inbound,
        fee: 0.01
      )

      attrs = [
        %{
          carrier_name: "Carrier B",
          client_code: "LIB25",
          client_name: "Lib Group",
          destination_number: "18014848755",
          direction: "inbound",
          number_of_units: "96",
          service: "voice",
          source_number: "17083986237",
          success: "true",
          timestamp: ~N[2021-06-01 00:00:01]
        },
        %{
          carrier_name: "Carrier B",
          client_code: "BIZ00",
          client_name: "Biznode",
          destination_number: "17148943322",
          direction: "inbound",
          number_of_units: "10",
          service: "voice",
          source_number: "16197558541",
          success: "true",
          timestamp: ~N[2020-12-31 23:59:59]
        }
      ]

      assert {:error, %{changes: %{client_code: "BIZ00"}} = changeset} = CDRs.create(attrs)

      assert errors_on(changeset) == %{
               amount: ["client fee not found for the CDR timestamp"]
             }

      assert Repo.aggregate(CDR, :count) == 0
    end
  end

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

    %{csv_file_path: "test/support/assets/cdrs.csv"}
  end

  describe "create_from_csv/1" do
    setup :insert_rates

    test "creates cdrs from a CSV file and insert file hash", %{csv_file_path: csv_file_path} do
      assert {:ok,
              [
                %CDR{
                  carrier_name: "Carrier B",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "12703665756",
                  direction: :outbound,
                  number_of_units: 40,
                  service: :voice,
                  source_number: "16013167018",
                  success: true,
                  amount: 1.68,
                  timestamp: ~N[2021-01-01 00:05:49]
                },
                %CDR{
                  carrier_name: "Carrier A",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "12705575114",
                  direction: :outbound,
                  number_of_units: 30,
                  service: :voice,
                  source_number: "19803395703",
                  success: true,
                  amount: 1.23,
                  timestamp: ~N[2021-01-01 00:07:01]
                },
                %CDR{
                  carrier_name: "Carrier B",
                  client_code: "LIB25",
                  client_name: "Lib Group",
                  destination_number: "12705575114",
                  direction: :outbound,
                  number_of_units: 20,
                  service: :voice,
                  source_number: "16619525945",
                  success: true,
                  amount: 0.64,
                  timestamp: ~N[2021-01-01 00:02:29]
                },
                %CDR{
                  carrier_name: "Carrier A",
                  client_code: "LIB25",
                  client_name: "Lib Group",
                  destination_number: "17066135090",
                  direction: :outbound,
                  number_of_units: 10,
                  service: :voice,
                  source_number: "12159538568",
                  success: true,
                  amount: 0.31,
                  timestamp: ~N[2021-01-01 00:01:03]
                }
              ]} = CDRs.create_from_csv(csv_file_path)

      file_hash = FileHashes.hash_file(csv_file_path)

      assert Repo.aggregate(CDR, :count) == 4

      assert %FileHash{hash: ^file_hash} = Repo.get_by(FileHash, hash: file_hash)
    end

    test "updates existing cdrs", %{csv_file_path: csv_file_path} do
      existing_cdr =
        insert(:cdr,
          carrier_name: "Carrier B",
          client_code: "BIZ00",
          client_name: "Biznode",
          destination_number: "12703665756",
          direction: :outbound,
          number_of_units: 50,
          service: :voice,
          source_number: "16013167018",
          success: true,
          amount: 2.05,
          timestamp: ~N[2021-01-01 00:05:49]
        )

      assert {:ok,
              [
                %CDR{
                  carrier_name: "Carrier B",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "12703665756",
                  direction: :outbound,
                  number_of_units: 40,
                  service: :voice,
                  source_number: "16013167018",
                  success: true,
                  amount: 1.68,
                  timestamp: ~N[2021-01-01 00:05:49]
                },
                %CDR{
                  carrier_name: "Carrier A",
                  client_code: "BIZ00",
                  client_name: "Biznode",
                  destination_number: "12705575114",
                  direction: :outbound,
                  number_of_units: 30,
                  service: :voice,
                  source_number: "19803395703",
                  success: true,
                  amount: 1.23,
                  timestamp: ~N[2021-01-01 00:07:01]
                },
                %CDR{
                  carrier_name: "Carrier B",
                  client_code: "LIB25",
                  client_name: "Lib Group",
                  destination_number: "12705575114",
                  direction: :outbound,
                  number_of_units: 20,
                  service: :voice,
                  source_number: "16619525945",
                  success: true,
                  amount: 0.64,
                  timestamp: ~N[2021-01-01 00:02:29]
                },
                %CDR{
                  carrier_name: "Carrier A",
                  client_code: "LIB25",
                  client_name: "Lib Group",
                  destination_number: "17066135090",
                  direction: :outbound,
                  number_of_units: 10,
                  service: :voice,
                  source_number: "12159538568",
                  success: true,
                  amount: 0.31,
                  timestamp: ~N[2021-01-01 00:01:03]
                }
              ]} = CDRs.create_from_csv(csv_file_path)

      assert Repo.aggregate(CDR, :count) == 4

      assert Repo.get_by(CDR,
               id: existing_cdr.id,
               inserted_at: existing_cdr.inserted_at,
               carrier_name: "Carrier B",
               client_code: "BIZ00",
               client_name: "Biznode",
               destination_number: "12703665756",
               direction: :outbound,
               number_of_units: 40,
               service: :voice,
               source_number: "16013167018",
               success: true,
               amount: 1.68,
               timestamp: ~N[2021-01-01 00:05:49]
             )

      file_hash = FileHashes.hash_file(csv_file_path)

      assert %FileHash{hash: ^file_hash} = Repo.get_by(FileHash, hash: file_hash)
    end

    test "return error when file has already been imported", %{csv_file_path: csv_file_path} do
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
