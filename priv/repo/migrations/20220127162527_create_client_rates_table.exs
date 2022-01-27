defmodule CDRex.Repo.Migrations.CreateClientRatesTable do
  use Ecto.Migration

  def up do
    create table(:client_rates) do
      add :client_code, :citext, null: false
      add :start_date, :date, null: false
      add :service, :service_type, null: false
      add :direction, :direction_type, null: false
      add :rate, :float, null: false

      timestamps()
    end

    create unique_index(
             :client_rates,
             [:direction, :service, :start_date, :client_code],
             name: :client_rates_unique_rate
           )

    create index(:client_rates, [:client_code])
  end

  def down do
    drop index(:client_rates, [:client_code])

    drop index(:client_rates, [:direction, :service, :start_date, :client_code])

    drop table(:client_rates)
  end
end
