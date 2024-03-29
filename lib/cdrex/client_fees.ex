defmodule CDRex.ClientFees do
  @moduledoc """
    The ClientFees context.
  """

  import Ecto.Query

  alias Ecto.{Changeset, Multi}

  alias CDRex.ClientFees.{Attrs, ClientFee}
  alias CDRex.{FileHashes, Parser}
  alias CDRex.Repo

  @doc """
    Returns a list of client fees by the client code ordered by `start_date` and `client_code`.
  """
  @spec list_by_client_code(list(String.t())) :: list(ClientFee.t())
  def list_by_client_code(client_codes) when is_list(client_codes) do
    ClientFee
    |> where([cf], cf.client_code in ^client_codes)
    |> order_by([:start_date, :client_code])
    |> Repo.all()
  end

  @doc """
    Creates client fees from a CSV file.
  """
  @spec create_from_csv(String.t()) :: {:ok, ClientFee.t()} | {:error, any()}
  def create_from_csv(csv_file_path) when is_binary(csv_file_path) do
    with {:ok, file_hash} <- FileHashes.validate(csv_file_path),
         {:ok, parsed_values} <- Parser.parse_csv_with_headers(csv_file_path),
         {:ok, attrs} <- Attrs.build(parsed_values),
         {:ok, attrs} <- validate_attrs(attrs),
         {:ok, client_fees} <- create(attrs, file_hash: file_hash) do
      {:ok, client_fees}
    else
      {:error, _} = error -> error
    end
  end

  @doc """
    Creates client fees from a list of attrs.
  """
  @spec create(list(String.t())) :: {:ok, list(ClientFee.t())} | {:error, any()}
  def create(attrs, opts \\ []) when is_list(attrs) do
    file_hash = Keyword.get(opts, :file_hash)

    Multi.new()
    |> Multi.insert_all(:client_fees, ClientFee, attrs,
      conflict_target: [:direction, :service, :start_date, :client_code],
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      returning: true
    )
    |> Multi.merge(fn _ -> handle_file_hash(file_hash) end)
    |> Repo.transaction()
    |> case do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{client_fees: {_, client_fees}}} -> {:ok, client_fees}
    end
  end

  defp handle_file_hash(nil), do: Multi.new()

  defp handle_file_hash(file_hash) do
    attrs = %{hash: file_hash}

    Multi.run(Multi.new(), :file_hash, fn _, _ -> FileHashes.create(attrs) end)
  end

  defp validate_attrs(attrs_list) do
    attrs_list
    |> Enum.reduce_while([], fn attrs, acc ->
      changeset = attrs |> Map.from_struct() |> ClientFee.changeset()

      case Changeset.apply_action(changeset, :insert) do
        {:ok, _client_fee} ->
          attrs = CDRex.Changeset.add_timestamps(changeset.changes)

          {:cont, [attrs | acc]}

        {:error, _} = error ->
          {:halt, error}
      end
    end)
    |> case do
      {:error, _} = error -> error
      attrs when is_list(attrs) -> {:ok, attrs}
    end
  end
end
