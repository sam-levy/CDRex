defmodule CDRex.Repo.Migrations.CreateDirectionType do
  use Ecto.Migration
  import EctoEnumMigration

  def up do
    create_type(:direction_type, [:inbound, :outbound])
  end

  def down do
    drop_type(:direction_type)
  end
end
