defmodule CDRex.Repo.Migrations.CreateCdrsTable do
  use Ecto.Migration

  def up do
    create table(:cdrs) do
      add :client_name, :citext, null: false
      add :client_code, :citext, null: false
      add :carrier_name, :citext, null: false
      add :source_number, :string, null: false
      add :destination_number, :string, null: false
      add :direction, :direction_type, null: false
      add :service, :service_type, null: false
      add :number_of_units, :integer, null: false
      add :success, :boolean, null: false
      add :timestamp, :naive_datetime, null: false

      timestamps()
    end

    create unique_index(
             :cdrs,
             [:client_code, :carrier_name, :source_number, :service, :timestamp],
             name: :cdrs_unique
           )

    create index(:cdrs, [:client_code])

    create index(:cdrs, [:carrier_name])
  end

  def down do
    drop index(:cdrs, [:carrier_name])

    drop index(:cdrs, [:client_code])

    drop index(:cdrs, [:client_code, :carrier_name, :source_number, :service, :timestamp])

    drop table(:cdrs)
  end
end
