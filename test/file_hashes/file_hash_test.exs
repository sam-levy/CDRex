defmodule CDRex.FileHashes.FileHashTest do
  use CDRex.DataCase, async: true

  alias CDRex.FileHashes.FileHash

  describe "file_hashes table constraints" do
    test "hash unique constraint" do
      existing_file_hash = insert(:file_hash)

      new_file_hash = %FileHash{
        hash: existing_file_hash.hash
      }

      assert_raise Ecto.ConstraintError,
                   ~r/file_hashes_pkey \(unique_constraint\)/,
                   fn -> Repo.insert(new_file_hash) end
    end
  end

  describe "changeset/2" do
    test "valid attrs" do
      attrs = %{
        hash: build_hash("File Content")
      }

      assert changeset = FileHash.changeset(attrs)

      assert changeset.valid?

      assert changeset.changes == %{
               hash: attrs[:hash]
             }
    end

    test "invalid attrs" do
      attrs = %{
        hash: :invalid
      }

      assert changeset = FileHash.changeset(attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               hash: ["is invalid"]
             }
    end

    test "missing required attrs" do
      assert changeset = FileHash.changeset(%{})

      refute changeset.valid?

      assert errors_on(changeset) == %{
               hash: ["can't be blank"]
             }
    end

    test "hash field length greater than 64 chars" do
      attrs = %{
        hash: String.duplicate("a", 65)
      }

      assert changeset = FileHash.changeset(attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               hash: ["should be at most 64 character(s)"]
             }
    end

    test "hash field unique constraint" do
      existing_file_hash = insert(:file_hash)

      attrs = %{
        hash: existing_file_hash.hash
      }

      assert {:error, changeset} =
               attrs
               |> FileHash.changeset()
               |> Repo.insert()

      assert errors_on(changeset) == %{
               hash: ["the file has already been imported"]
             }
    end
  end
end
