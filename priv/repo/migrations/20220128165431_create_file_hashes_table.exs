defmodule CDRex.Repo.Migrations.CreateFileHashesTable do
  use Ecto.Migration

  def up do
    create table(:file_hashes, primary_key: false) do
      add :hash, :string, primary_key: true, size: 100

      timestamps(updated_at: false)
    end
  end

  def down do
    drop table(:file_hashes)
  end
end
