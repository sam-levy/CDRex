defmodule CDRex.CarrierRates do
  alias Ecto.{Changeset, Multi}

  alias CDRex.CarrierRates.{Attrs, CarrierRate}
  alias CDRex.{FileHashes, Parser}
  alias CDRex.Repo

  def create_from_csv(csv_file_path) when is_binary(csv_file_path) do
    with {:ok, file_hash} <- FileHashes.validate(csv_file_path),
         {:ok, parsed_values} <- Parser.parse_csv_with_headers(csv_file_path),
         {:ok, attrs} <- Attrs.build(parsed_values),
         {:ok, attrs} <- validate_attrs(attrs),
         {:ok, carrier_rates} <- create(attrs, file_hash: file_hash) do
      {:ok, carrier_rates}
    else
      {:error, _} = error -> error
    end
  end

  def create(attrs, opts \\ []) when is_list(attrs) do
    file_hash = Keyword.get(opts, :file_hash)

    Multi.new()
    |> Multi.insert_all(:carrier_rates, CarrierRate, attrs,
      conflict_target: [:direction, :service, :start_date, :carrier_name],
      on_conflict: {:replace, [:start_date, :rate, :updated_at]},
      returning: true
    )
    |> Multi.merge(fn _ -> handle_file_hash(file_hash) end)
    |> Repo.transaction()
    |> case do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{carrier_rates: {_, carrier_rates}}} -> {:ok, carrier_rates}
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
      changeset = attrs |> Map.from_struct() |> CarrierRate.changeset()

      case Changeset.apply_action(changeset, :insert) do
        {:ok, _carrier_rate} ->
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