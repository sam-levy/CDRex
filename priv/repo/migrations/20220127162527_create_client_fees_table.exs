defmodule CDRex.Repo.Migrations.CreateClientFeesTable do
  use Ecto.Migration

  def up do
    create table(:client_fees) do
      add :client_code, :citext, null: false
      add :start_date, :date, null: false
      add :service, :service_type, null: false
      add :direction, :direction_type, null: false
      add :fee, :float, null: false

      timestamps()
    end

    create unique_index(
             :client_fees,
             [:direction, :service, :start_date, :client_code],
             name: :client_fees_unique_fee
           )

    create index(:client_fees, [:client_code])
  end

  def down do
    drop index(:client_fees, [:client_code])

    drop index(:client_fees, [:direction, :service, :start_date, :client_code])

    drop table(:client_fees)
  end
end
