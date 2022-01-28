defmodule CDRex.ClientFees.ClientFeeTest do
  use CDRex.DataCase, async: true

  alias CDRex.ClientFees.ClientFee

  describe "client_fees table constraints" do
    test "`client_fees_unique_fee` unique constraint" do
      existing_client_fee =
        insert(:client_fee,
          client_code: "ABC12",
          start_date: Date.utc_today(),
          fee: 0.001,
          service: :sms,
          direction: :inbound
        )

      # Allow different client code
      insert(:client_fee,
        client_code: "DEF34",
        start_date: Date.utc_today(),
        fee: 0.001,
        service: :sms,
        direction: :inbound
      )

      # Allow different start_date
      insert(:client_fee,
        client_code: "ABC12",
        start_date: Date.utc_today() |> Date.add(1),
        fee: 0.001,
        service: :sms,
        direction: :inbound
      )

      # Allow different service
      insert(:client_fee,
        client_code: "ABC12",
        start_date: Date.utc_today(),
        fee: 0.001,
        service: :voice,
        direction: :inbound
      )

      # Allow different direction
      insert(:client_fee,
        client_code: "ABC12",
        start_date: Date.utc_today(),
        fee: 0.001,
        service: :sms,
        direction: :outbound
      )

      new_client_fee = %ClientFee{
        client_code: existing_client_fee.client_code,
        start_date: existing_client_fee.start_date,
        fee: existing_client_fee.fee,
        service: existing_client_fee.service,
        direction: existing_client_fee.direction
      }

      assert_raise Ecto.ConstraintError,
                   ~r/client_fees_unique_fee \(unique_constraint\)/,
                   fn -> Repo.insert(new_client_fee) end
    end

    test "`client_code` field citext unique constraint" do
      existing_client_fee =
        insert(:client_fee,
          client_code: "ABC12",
          start_date: random_past_date(),
          fee: random_rate(),
          service: random_service_type(),
          direction: random_direction_type()
        )

      new_client_fee = %ClientFee{
        client_code: "aBC12",
        start_date: existing_client_fee.start_date,
        fee: existing_client_fee.fee,
        service: existing_client_fee.service,
        direction: existing_client_fee.direction
      }

      assert_raise Ecto.ConstraintError,
                   ~r/client_fees_unique_fee \(unique_constraint\)/,
                   fn -> Repo.insert(new_client_fee) end
    end
  end

  describe "changeset/2" do
    test "valid attrs" do
      attrs = %{
        client_code: "ABC12",
        start_date: Date.utc_today(),
        fee: 0.001,
        service: :sms,
        direction: :inbound
      }

      assert changeset = ClientFee.changeset(attrs)

      assert changeset.valid?

      assert changeset.changes == %{
               client_code: attrs[:client_code],
               start_date: attrs[:start_date],
               fee: attrs[:fee],
               service: attrs[:service],
               direction: attrs[:direction]
             }
    end

    test "invalid attrs" do
      attrs = %{
        client_code: :invalid,
        start_date: :invalid,
        fee: :invalid,
        service: :invalid,
        direction: :invalid
      }

      assert changeset = ClientFee.changeset(attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               client_code: ["is invalid"],
               direction: ["is invalid"],
               fee: ["is invalid"],
               service: ["is invalid"],
               start_date: ["is invalid"]
             }
    end

    test "missing required attr" do
      assert changeset = ClientFee.changeset(%{})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               client_code: ["can't be blank"],
               direction: ["can't be blank"],
               fee: ["can't be blank"],
               service: ["can't be blank"],
               start_date: ["can't be blank"]
             }
    end

    test "`client_code` length greater than 255 chars" do
      attrs = %{
        client_code: String.duplicate("a", 256),
        start_date: Date.utc_today(),
        fee: 0.001,
        service: :sms,
        direction: :inbound
      }

      assert changeset = ClientFee.changeset(attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               client_code: ["should be at most 255 character(s)"]
             }
    end

    test "`client_fees_unique_fee` unique constraint" do
      existing_client_fee =
        insert(:client_fee,
          client_code: "ABC12",
          start_date: Date.utc_today(),
          fee: 0.001,
          service: :sms,
          direction: :inbound
        )

      attrs = %{
        client_code: existing_client_fee.client_code,
        start_date: existing_client_fee.start_date,
        fee: existing_client_fee.fee,
        service: existing_client_fee.service,
        direction: existing_client_fee.direction
      }

      assert {:error, changeset} =
               attrs
               |> ClientFee.changeset()
               |> Repo.insert()

      assert errors_on(changeset) == %{
               direction: [
                 "The fee for this client_code, start_date, service and direction already exists"
               ]
             }
    end
  end
end
