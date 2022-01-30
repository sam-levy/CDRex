defmodule CDRex.FileHashes do
  @moduledoc """
    The FileHashes context.
  """

  alias CDRex.FileHashes.FileHash
  alias CDRex.Repo

  @doc """
    Calculates the `SHA256` hash of a file from the path.
  """
  @spec hash_file(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def hash_file(file_path) do
    file_hash =
      file_path
      |> File.stream!([], 2_048)
      |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
      |> :crypto.hash_final()
      |> Base.encode16()
      |> String.downcase()

    {:ok, file_hash}
  rescue
    _ -> {:error, "file not found"}
  end

  @doc """
    Checks if a file has already been persisted.
  """
  @spec validate(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def validate(file_path) do
    with {:ok, file_hash} <- hash_file(file_path),
         nil <- Repo.get_by(FileHash, hash: file_hash) do
      {:ok, file_hash}
    else
      %FileHash{} -> {:error, "the file has already been imported"}
      {:error, _} = error -> error
    end
  end

  @doc """
    Inserts a file hash.
  """
  @spec create(map()) :: {:ok, FileHash.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    attrs
    |> FileHash.changeset()
    |> Repo.insert()
  end
end
