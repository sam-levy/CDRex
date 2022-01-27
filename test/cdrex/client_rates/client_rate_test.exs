defmodule CDRex.ClientRates.ClientRateTest do
  use CDRex.DataCase, async: true

  alias CDRex.ClientRates.ClientRate

  describe "client_rates table constraints" do
    test "`client_rates_unique_rate` unique constraint" do
      existing_client_rate =
        insert(:client_rate,
          client_code: "ABC12",
          start_date: Date.utc_today(),
          rate: 0.001,
          service: :sms,
          direction: :inbound
        )

      # Allow different client code
      insert(:client_rate,
        client_code: "DEF34",
        start_date: Date.utc_today(),
        rate: 0.001,
        service: :sms,
        direction: :inbound
      )

      # Allow different start_date
      insert(:client_rate,
        client_code: "ABC12",
        start_date: Date.utc_today() |> Date.add(1),
        rate: 0.001,
        service: :sms,
        direction: :inbound
      )

      # Allow different service
      insert(:client_rate,
        client_code: "ABC12",
        start_date: Date.utc_today(),
        rate: 0.001,
        service: :voice,
        direction: :inbound
      )

      # Allow different direction
      insert(:client_rate,
        client_code: "ABC12",
        start_date: Date.utc_today(),
        rate: 0.001,
        service: :sms,
        direction: :outbound
      )

      new_client_rate = %ClientRate{
        client_code: existing_client_rate.client_code,
        start_date: existing_client_rate.start_date,
        rate: existing_client_rate.rate,
        service: existing_client_rate.service,
        direction: existing_client_rate.direction
      }

      assert_raise Ecto.ConstraintError,
                   ~r/client_rates_unique_rate \(unique_constraint\)/,
                   fn -> Repo.insert(new_client_rate) end
    end

    test "`client_code` field citext unique constraint" do
      existing_client_rate =
        insert(:client_rate,
          client_code: "ABC12",
          start_date: random_past_date(),
          rate: random_rate(),
          service: random_service_type(),
          direction: random_direction_type()
        )

      new_client_rate = %ClientRate{
        client_code: "aBC12",
        start_date: existing_client_rate.start_date,
        rate: existing_client_rate.rate,
        service: existing_client_rate.service,
        direction: existing_client_rate.direction
      }

      assert_raise Ecto.ConstraintError,
                   ~r/client_rates_unique_rate \(unique_constraint\)/,
                   fn -> Repo.insert(new_client_rate) end
    end
  end

  describe "changeset/2" do
    test "valid attrs" do
      attrs = %{
        client_code: "ABC12",
        start_date: Date.utc_today(),
        rate: 0.001,
        service: :sms,
        direction: :inbound
      }

      assert changeset = ClientRate.changeset(attrs)

      assert changeset.valid?

      assert changeset.changes == %{
               client_code: attrs[:client_code],
               start_date: attrs[:start_date],
               rate: attrs[:rate],
               service: attrs[:service],
               direction: attrs[:direction]
             }
    end

    test "invalid attrs" do
      attrs = %{
        client_code: :invalid,
        start_date: :invalid,
        rate: :invalid,
        service: :invalid,
        direction: :invalid
      }

      assert changeset = ClientRate.changeset(attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               client_code: ["is invalid"],
               direction: ["is invalid"],
               rate: ["is invalid"],
               service: ["is invalid"],
               start_date: ["is invalid"]
             }
    end

    test "missing required attr" do
      assert changeset = ClientRate.changeset(%{})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               client_code: ["can't be blank"],
               direction: ["can't be blank"],
               rate: ["can't be blank"],
               service: ["can't be blank"],
               start_date: ["can't be blank"]
             }
    end

    test "`client_code` length greater than 255 chars" do
      attrs = %{
        client_code: String.duplicate("a", 256),
        start_date: Date.utc_today(),
        rate: 0.001,
        service: :sms,
        direction: :inbound
      }

      assert changeset = ClientRate.changeset(attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               client_code: ["should be at most 255 character(s)"]
             }
    end

    test "`client_rates_unique_rate` unique constraint" do
      existing_client_rate =
        insert(:client_rate,
          client_code: "ABC12",
          start_date: Date.utc_today(),
          rate: 0.001,
          service: :sms,
          direction: :inbound
        )

      attrs = %{
        client_code: existing_client_rate.client_code,
        start_date: existing_client_rate.start_date,
        rate: existing_client_rate.rate,
        service: existing_client_rate.service,
        direction: existing_client_rate.direction
      }

      assert {:error, changeset} =
               attrs
               |> ClientRate.changeset()
               |> Repo.insert()

      assert errors_on(changeset) == %{
               direction: [
                 "The rate for this client_code, start_date, service and direction already exists"
               ]
             }
    end
  end
end
