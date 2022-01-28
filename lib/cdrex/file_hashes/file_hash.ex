defmodule CDRex.FileHashes.FileHash do
  use CDRex.Schema

  @primary_key false
  schema "file_hashes" do
    field :hash, :string, primary_key: true

    timestamps(updated_at: false)
  end

  def changeset(target \\ %__MODULE__{}, attrs) do
    target
    |> cast(attrs, [:hash])
    |> validate_required([:hash])
    |> validate_length(:hash, max: 64)
    |> unique_constraint([:hash],
      name: :file_hashes_pkey,
      message: "the file has already been imported"
    )
  end
end
