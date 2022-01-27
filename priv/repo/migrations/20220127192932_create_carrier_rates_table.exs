defmodule CDRex.Repo.Migrations.CreateCarrierRatesTable do
  use Ecto.Migration

  def up do
    create table(:carrier_rates) do
      add :carrier_name, :citext, null: false
      add :start_date, :date, null: false
      add :service, :service_type, null: false
      add :direction, :direction_type, null: false
      add :rate, :float, null: false

      timestamps()
    end

    create unique_index(
             :carrier_rates,
             [:direction, :service, :start_date, :carrier_name],
             name: :carrier_rates_unique_rate
           )

    create index(:carrier_rates, [:carrier_name])
  end

  def down do
    drop index(:carrier_rates, [:carrier_name])

    drop index(:carrier_rates, [:direction, :service, :start_date, :carrier_name])

    drop table(:carrier_rates)
  end
end
