defmodule CDRex.Repo.Migrations.CreateServiceType do
  use Ecto.Migration
  import EctoEnumMigration

  def up do
    create_type(:service_type, [:sms, :mms, :voice])
  end

  def down do
    drop_type(:service_type)
  end
end
