defmodule CDRex.FileHashes do
  @moduledoc """
    The FileHashes context.
  """

  alias CDRex.FileHashes.FileHash
  alias CDRex.Repo

  @doc """
    Calculates the `SHA256` hash of a file from the path.
  """
  def hash_file(file_path) do
    file_path
    |> File.stream!([], 2_048)
    |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  rescue
    _ -> {:error, "file not found"}
  end

  @doc """
    Checks if a file has already been persisted.
  """
  def validate(file_path) do
    file_hash = hash_file(file_path)

    case Repo.get_by(FileHash, hash: file_hash) do
      nil -> {:ok, file_hash}
      %FileHash{} -> {:error, "the file has already been imported"}
    end
  end

  @doc """
    Inserts a file hash.
  """
  def create(attrs) do
    attrs
    |> FileHash.changeset()
    |> Repo.insert()
  end
end
