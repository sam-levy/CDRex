defmodule CDRex.CarrierRates.CarrierRateTest do
  use CDRex.DataCase, async: true

  alias CDRex.CarrierRates.CarrierRate

  describe "carrier_rates table constraints" do
    test "`carrier_rates_unique_rate` unique constraint" do
      existing_carrier_rate =
        insert(:carrier_rate,
          carrier_name: "ABC12",
          start_date: Date.utc_today(),
          rate: 0.001,
          service: :sms,
          direction: :inbound
        )

      # Allow different carrier name
      insert(:carrier_rate,
        carrier_name: "DEF34",
        start_date: Date.utc_today(),
        rate: 0.001,
        service: :sms,
        direction: :inbound
      )

      # Allow different start_date
      insert(:carrier_rate,
        carrier_name: "ABC12",
        start_date: Date.utc_today() |> Date.add(1),
        rate: 0.001,
        service: :sms,
        direction: :inbound
      )

      # Allow different service
      insert(:carrier_rate,
        carrier_name: "ABC12",
        start_date: Date.utc_today(),
        rate: 0.001,
        service: :voice,
        direction: :inbound
      )

      # Allow different direction
      insert(:carrier_rate,
        carrier_name: "ABC12",
        start_date: Date.utc_today(),
        rate: 0.001,
        service: :sms,
        direction: :outbound
      )

      new_carrier_rate = %CarrierRate{
        carrier_name: existing_carrier_rate.carrier_name,
        start_date: existing_carrier_rate.start_date,
        rate: existing_carrier_rate.rate,
        service: existing_carrier_rate.service,
        direction: existing_carrier_rate.direction
      }

      assert_raise Ecto.ConstraintError,
                   ~r/carrier_rates_unique_rate \(unique_constraint\)/,
                   fn -> Repo.insert(new_carrier_rate) end
    end

    test "`carrier_name` field citext unique constraint" do
      existing_carrier_rate =
        insert(:carrier_rate,
          carrier_name: "ABC12",
          start_date: random_past_date(),
          rate: random_rate(),
          service: random_service_type(),
          direction: random_direction_type()
        )

      new_carrier_rate = %CarrierRate{
        carrier_name: "aBC12",
        start_date: existing_carrier_rate.start_date,
        rate: existing_carrier_rate.rate,
        service: existing_carrier_rate.service,
        direction: existing_carrier_rate.direction
      }

      assert_raise Ecto.ConstraintError,
                   ~r/carrier_rates_unique_rate \(unique_constraint\)/,
                   fn -> Repo.insert(new_carrier_rate) end
    end
  end

  describe "changeset/2" do
    test "valid attrs" do
      attrs = %{
        carrier_name: "ABC12",
        start_date: Date.utc_today(),
        rate: 0.001,
        service: :sms,
        direction: :inbound
      }

      assert changeset = CarrierRate.changeset(attrs)

      assert changeset.valid?

      assert changeset.changes == %{
               carrier_name: attrs[:carrier_name],
               start_date: attrs[:start_date],
               rate: attrs[:rate],
               service: attrs[:service],
               direction: attrs[:direction]
             }
    end

    test "invalid attrs" do
      attrs = %{
        carrier_name: :invalid,
        start_date: :invalid,
        rate: :invalid,
        service: :invalid,
        direction: :invalid
      }

      assert changeset = CarrierRate.changeset(attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               carrier_name: ["is invalid"],
               direction: ["is invalid"],
               rate: ["is invalid"],
               service: ["is invalid"],
               start_date: ["is invalid"]
             }
    end

    test "missing required attr" do
      assert changeset = CarrierRate.changeset(%{})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               carrier_name: ["can't be blank"],
               direction: ["can't be blank"],
               rate: ["can't be blank"],
               service: ["can't be blank"],
               start_date: ["can't be blank"]
             }
    end

    test "`carrier_name` length greater than 255 chars" do
      attrs = %{
        carrier_name: String.duplicate("a", 256),
        start_date: Date.utc_today(),
        rate: 0.001,
        service: :sms,
        direction: :inbound
      }

      assert changeset = CarrierRate.changeset(attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               carrier_name: ["should be at most 255 character(s)"]
             }
    end

    test "`carrier_rates_unique_rate` unique constraint" do
      existing_carrier_rate =
        insert(:carrier_rate,
          carrier_name: "ABC12",
          start_date: Date.utc_today(),
          rate: 0.001,
          service: :sms,
          direction: :inbound
        )

      attrs = %{
        carrier_name: existing_carrier_rate.carrier_name,
        start_date: existing_carrier_rate.start_date,
        rate: existing_carrier_rate.rate,
        service: existing_carrier_rate.service,
        direction: existing_carrier_rate.direction
      }

      assert {:error, changeset} =
               attrs
               |> CarrierRate.changeset()
               |> Repo.insert()

      assert errors_on(changeset) == %{
               direction: [
                 "The rate for this carrier_name, start_date, service and direction already exists"
               ]
             }
    end
  end
end
