defmodule CDRex.CDRs.CDRTest do
  use CDRex.DataCase, async: true

  alias CDRex.CDRs.CDR

  describe "cdrs table constraints" do
    test "`carrier_rates_unique_rate` unique constraint" do
      timestamp = truncated_naivedatetime()

      existing_cdr =
        insert(:cdr,
          client_code: "ABC12",
          carrier_name: "Carrier A",
          source_number: "1234567",
          service: :sms,
          timestamp: timestamp
        )

      # Allow different cilent_code
      insert(:cdr,
        client_code: "DEF34",
        carrier_name: "Carrier A",
        source_number: "1234567",
        service: :sms,
        timestamp: timestamp
      )

      # Allow different carrier_name
      insert(:cdr,
        client_code: "ABC12",
        carrier_name: "Carrier B",
        source_number: "1234567",
        service: :sms,
        timestamp: timestamp
      )

      # Allow different source_number
      insert(:cdr,
        client_code: "ABC12",
        carrier_name: "Carrier A",
        source_number: "89101112",
        service: :sms,
        timestamp: timestamp
      )

      # Allow different servcie
      insert(:cdr,
        client_code: "ABC12",
        carrier_name: "Carrier A",
        source_number: "1234567",
        service: :voice,
        timestamp: timestamp
      )

      # Allow different timestamp
      insert(:cdr,
        client_code: "ABC12",
        carrier_name: "Carrier A",
        source_number: "1234567",
        service: :sms,
        timestamp: truncated_naivedatetime() |> NaiveDateTime.add(-100)
      )

      new_cdr = %CDR{
        client_code: existing_cdr.client_code,
        carrier_name: existing_cdr.carrier_name,
        source_number: existing_cdr.source_number,
        service: existing_cdr.service,
        timestamp: existing_cdr.timestamp,
        client_name: existing_cdr.client_name,
        destination_number: random_string_number(),
        direction: random_direction_type(),
        success: true,
        number_of_units: number_of_units(),
        amount: number_of_units() * random_rate()
      }

      assert_raise Ecto.ConstraintError,
                   ~r/cdrs_unique \(unique_constraint\)/,
                   fn -> Repo.insert(new_cdr) end
    end

    test "`client_code` field citext unique constraint" do
      timestamp = truncated_naivedatetime()

      existing_cdr =
        insert(:cdr,
          client_code: "ABC12",
          carrier_name: "Carrier A",
          source_number: "1234567",
          service: :sms,
          timestamp: timestamp
        )

      new_cdr = %CDR{
        client_code: "aBC12",
        carrier_name: existing_cdr.carrier_name,
        source_number: existing_cdr.source_number,
        service: existing_cdr.service,
        timestamp: existing_cdr.timestamp,
        client_name: existing_cdr.client_name,
        destination_number: random_string_number(),
        direction: random_direction_type(),
        success: true,
        number_of_units: number_of_units(),
        amount: number_of_units() * random_rate()
      }

      assert_raise Ecto.ConstraintError,
                   ~r/cdrs_unique \(unique_constraint\)/,
                   fn -> Repo.insert(new_cdr) end
    end

    test "`carrier_name` field citext unique constraint" do
      timestamp = truncated_naivedatetime()

      existing_cdr =
        insert(:cdr,
          client_code: "ABC12",
          carrier_name: "Carrier A",
          source_number: "1234567",
          service: :sms,
          timestamp: timestamp
        )

      new_cdr = %CDR{
        client_code: existing_cdr.client_code,
        carrier_name: "CARRIER A",
        source_number: existing_cdr.source_number,
        service: existing_cdr.service,
        timestamp: existing_cdr.timestamp,
        client_name: existing_cdr.client_name,
        destination_number: random_string_number(),
        direction: random_direction_type(),
        success: true,
        number_of_units: number_of_units(),
        amount: number_of_units() * random_rate()
      }

      assert_raise Ecto.ConstraintError,
                   ~r/cdrs_unique \(unique_constraint\)/,
                   fn -> Repo.insert(new_cdr) end
    end
  end

  describe "changeset/2" do
    test "valid attrs" do
      attrs = %{
        client_name: "Client_1",
        client_code: "ABC12",
        carrier_name: "Carrier_A",
        source_number: "1234567",
        destination_number: "89101112",
        direction: :inbound,
        service: :sms,
        number_of_units: 10,
        success: true,
        timestamp: truncated_naivedatetime(),
        amount: 2.0
      }

      assert changeset = CDR.changeset(attrs)

      assert changeset.valid?

      assert changeset.changes == %{
               client_name: attrs[:client_name],
               client_code: attrs[:client_code],
               carrier_name: attrs[:carrier_name],
               source_number: attrs[:source_number],
               destination_number: attrs[:destination_number],
               direction: attrs[:direction],
               service: attrs[:service],
               number_of_units: attrs[:number_of_units],
               success: attrs[:success],
               timestamp: attrs[:timestamp],
               amount: attrs[:amount]
             }
    end

    test "invalid attrs" do
      attrs = %{
        client_name: :invalid,
        client_code: :invalid,
        carrier_name: :invalid,
        source_number: :invalid,
        destination_number: :invalid,
        direction: :invalid,
        service: :invalid,
        number_of_units: :invalid,
        success: :invalid,
        timestamp: :invalid,
        amount: :invalid
      }

      assert changeset = CDR.changeset(attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               carrier_name: ["is invalid"],
               client_code: ["is invalid"],
               client_name: ["is invalid"],
               destination_number: ["is invalid"],
               direction: ["is invalid"],
               number_of_units: ["is invalid"],
               service: ["is invalid"],
               source_number: ["is invalid"],
               success: ["is invalid"],
               timestamp: ["is invalid"],
               amount: ["is invalid"]
             }
    end

    test "missing required attrs" do
      assert changeset = CDR.changeset(%{})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               carrier_name: ["can't be blank"],
               client_code: ["can't be blank"],
               client_name: ["can't be blank"],
               destination_number: ["can't be blank"],
               direction: ["can't be blank"],
               number_of_units: ["can't be blank"],
               service: ["can't be blank"],
               source_number: ["can't be blank"],
               success: ["can't be blank"],
               timestamp: ["can't be blank"],
               amount: ["can't be blank"]
             }
    end

    test "string fields length greater than 255 chars" do
      attrs = %{
        client_name: String.duplicate("a", 256),
        client_code: String.duplicate("a", 256),
        carrier_name: String.duplicate("a", 256),
        source_number: "1234567",
        destination_number: "89101112",
        direction: :inbound,
        service: :sms,
        number_of_units: 10,
        success: true,
        timestamp: truncated_naivedatetime(),
        amount: 2.0
      }

      assert changeset = CDR.changeset(attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               carrier_name: ["should be at most 255 character(s)"],
               client_code: ["should be at most 255 character(s)"],
               client_name: ["should be at most 255 character(s)"]
             }
    end

    test "`cdrs_unique` unique constraint" do
      timestamp = truncated_naivedatetime()

      existing_cdr =
        insert(:cdr,
          client_code: "ABC12",
          carrier_name: "Carrier A",
          source_number: "1234567",
          service: :sms,
          timestamp: timestamp
        )

      attrs = %{
        client_code: existing_cdr.client_code,
        carrier_name: existing_cdr.carrier_name,
        source_number: existing_cdr.source_number,
        service: existing_cdr.service,
        timestamp: existing_cdr.timestamp,
        client_name: existing_cdr.client_name,
        destination_number: random_string_number(),
        direction: random_direction_type(),
        success: true,
        number_of_units: number_of_units(),
        amount: 2.0
      }

      assert {:error, changeset} =
               attrs
               |> CDR.changeset()
               |> Repo.insert()

      assert errors_on(changeset) == %{
               client_code: ["the CDR already exists"]
             }
    end
  end

  describe "base_changeset/2" do
    test "missing required attr ignores amount" do
      assert changeset = CDR.base_changeset(%{})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               carrier_name: ["can't be blank"],
               client_code: ["can't be blank"],
               client_name: ["can't be blank"],
               destination_number: ["can't be blank"],
               direction: ["can't be blank"],
               number_of_units: ["can't be blank"],
               service: ["can't be blank"],
               source_number: ["can't be blank"],
               success: ["can't be blank"],
               timestamp: ["can't be blank"]
             }
    end
  end
end
