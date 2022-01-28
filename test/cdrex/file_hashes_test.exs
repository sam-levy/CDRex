defmodule CDRex.FileHashesTest do
  use CDRex.DataCase, async: true

  alias CDRex.FileHashes
  alias CDRex.FileHashes.FileHash

  describe "hash_file/1" do
    test "hashes a file" do
      csv_file_path = "test/support/assets/buy_rates.csv"

      assert file_hash = FileHashes.hash_file(csv_file_path)

      assert String.length(file_hash) == 64
    end

    test "when file path is invalid" do
      csv_file_path = "test/support/assets/non_existent.csv"

      assert FileHashes.hash_file(csv_file_path) == {:error, "file not found"}
    end
  end

  describe "validate/1" do
    test "validates if a file has not been imported" do
      csv_file_path = "test/support/assets/buy_rates.csv"

      assert {:ok, file_hash} = FileHashes.validate(csv_file_path)

      assert String.length(file_hash) == 64
    end

    test "when the file has already been imported" do
      csv_file_path = "test/support/assets/buy_rates.csv"

      file_hash = FileHashes.hash_file(csv_file_path)

      insert(:file_hash, hash: file_hash)

      assert FileHashes.validate(csv_file_path) == {:error, "the file has already been imported"}
    end

    test "when files are different" do
      existing_csv_file_path = "test/support/assets/buy_rates.csv"

      file_hash = FileHashes.hash_file(existing_csv_file_path)

      _existing_file = insert(:file_hash, hash: file_hash)

      new_csv_file_path = "test/support/assets/sell_rates.csv"

      assert {:ok, _file_hash} = FileHashes.validate(new_csv_file_path)
    end
  end

  describe "create/1" do
    test "creates a file hash" do
      hash = build_hash("File Content")

      attrs = %{
        hash: hash
      }

      assert {:ok, %FileHash{hash: ^hash}} = FileHashes.create(attrs)

      assert %FileHash{hash: ^hash} = Repo.get_by(FileHash, hash: hash)
    end

    test "returns changeset errors" do
      attrs = %{
        hash: :invalid
      }

      assert {:error, changeset} = FileHashes.create(attrs)

      assert errors_on(changeset) == %{
        hash: ["is invalid"]
      }
    end
  end
end
