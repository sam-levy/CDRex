defmodule CDRex.CDRs do
  import Ecto.Changeset, only: [add_error: 3]

  alias Ecto.{Changeset, Multi}

  alias CDRex.CDRs.{Attrs, CDR}
  alias CDRex.CarrierRates
  alias CDRex.ClientFees
  alias CDRex.{FileHashes, Parser}
  alias CDRex.Repo

  def create(attrs, opts \\ [])

  def create(%{} = attrs, opts), do: create([attrs], opts)

  def create(attrs_list, opts) when is_list(attrs_list) do
    with {:ok, attrs_list} <- handle_attrs(attrs_list),
         {:ok, cdrs} <- create_multi(attrs_list, opts) do
      {:ok, cdrs}
    else
      {:error, _} = error -> error
    end
  end

  def create_from_csv(csv_file_path) when is_binary(csv_file_path) do
    with {:ok, file_hash} <- FileHashes.validate(csv_file_path),
         {:ok, parsed_values} <- Parser.parse_csv_with_headers(csv_file_path),
         {:ok, attrs} <- Attrs.build(parsed_values),
         {:ok, cdrs} <- create(attrs, file_hash: file_hash) do
      {:ok, cdrs}
    else
      {:error, _} = error -> error
    end
  end

  defp create_multi(attrs_list, opts) do
    file_hash = Keyword.get(opts, :file_hash)

    Multi.new()
    |> Multi.insert_all(:cdrs, CDR, attrs_list,
      conflict_target: [:client_code, :carrier_name, :source_number, :service, :timestamp],
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      returning: true
    )
    |> Multi.merge(fn _ -> handle_file_hash(file_hash) end)
    |> Repo.transaction()
    |> case do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{cdrs: {_, cdrs}}} -> {:ok, cdrs}
    end
  end

  defp handle_file_hash(nil), do: Multi.new()

  defp handle_file_hash(file_hash) do
    Multi.run(Multi.new(), :file_hash, fn _, _ -> FileHashes.create(%{hash: file_hash}) end)
  end

  defp handle_attrs(attrs_list) do
    %{carrier_names: carrier_names, client_codes: client_codes} =
      get_carriers_and_clients(attrs_list)

    indexed_carrier_rates =
      carrier_names
      |> CarrierRates.list_by_carrier_name()
      |> Enum.reduce(%{}, fn cr, acc ->
        key = {String.downcase(cr.carrier_name), cr.service, cr.direction}
        values = Map.get(acc, key, [])

        Map.put(acc, key, [cr | values])
      end)

    indexed_client_fees =
      client_codes
      |> ClientFees.list_by_client_code()
      |> Enum.reduce(%{}, fn cf, acc ->
        key = {String.downcase(cf.client_code), cf.service, cf.direction}
        values = Map.get(acc, key, [])

        Map.put(acc, key, [cf | values])
      end)

    attrs_list
    |> Enum.reduce_while([], fn attrs, acc ->
      attrs
      |> build_base_changeset()
      |> calculate_amount(indexed_carrier_rates, indexed_client_fees)
      |> validate_changeset(acc)
    end)
    |> case do
      {:error, _} = error -> error
      attrs when is_list(attrs) -> {:ok, attrs}
    end
  end

  defp get_carriers_and_clients(attrs_list) do
    acc = %{carrier_names: [], client_codes: []}

    Enum.reduce(attrs_list, acc, fn attrs, acc ->
      carrier_name = Map.get(attrs, :carrier_name)
      client_code = Map.get(attrs, :client_code)

      %{
        acc
        | carrier_names: [carrier_name | acc.carrier_names],
          client_codes: [client_code | acc.client_codes]
      }
    end)
  end

  defp build_base_changeset(attrs) when is_struct(attrs) do
    attrs |> Map.from_struct() |> CDR.base_changeset()
  end

  defp build_base_changeset(%{} = attrs), do: CDR.base_changeset(attrs)

  defp calculate_amount(
         %{valid?: false} = changeset,
         _indexed_carrier_rates,
         _indexed_client_fees
       ) do
    changeset
  end

  defp calculate_amount(
         %{changes: %{success: false}} = changeset,
         _indexed_carrier_rates,
         _indexed_client_fees
       ) do
    CDR.put_changeset_amount(changeset, 0)
  end

  defp calculate_amount(changeset, indexed_carrier_rates, indexed_client_fees) do
    %{number_of_units: number_of_units} = changeset.changes

    case fetch_rates(indexed_carrier_rates, indexed_client_fees, changeset.changes) do
      {:ok, %{carrier_rate: carrier_rate, client_fee: client_fee}} ->
        amount = ((carrier_rate + client_fee) * number_of_units) |> Float.round(4)

        CDR.put_changeset_amount(changeset, amount)

      {:error, message} ->
        add_error(changeset, :amount, message)
    end
  end

  def fetch_rates(indexed_carrier_rates, indexed_client_fees, attrs) do
    %{
      carrier_name: carrier_name,
      client_code: client_code,
      service: service,
      direction: direction,
      timestamp: timestamp
    } = attrs

    carrier_rate_key = {String.downcase(carrier_name), service, direction}
    client_fee_key = {String.downcase(client_code), service, direction}

    with {:ok, carrier_rates} <-
           get_items("carrier rate", indexed_carrier_rates, carrier_rate_key),
         {:ok, client_fees} <- get_items("client fee", indexed_client_fees, client_fee_key),
         {:ok, %{rate: carrier_rate}} <- get_item("carrier rate", carrier_rates, timestamp),
         {:ok, %{fee: client_fee}} <- get_item("client fee", client_fees, timestamp) do
      {:ok, %{carrier_rate: carrier_rate, client_fee: client_fee}}
    else
      {:error, _} = error -> error
    end
  end

  defp get_items(type, indexed_items, index) do
    case Map.get(indexed_items, index) do
      nil -> {:error, "#{type} not found for the CDR"}
      items -> {:ok, items}
    end
  end

  defp get_item(type, items, timestamp) do
    case items
         |> Enum.reject(&(Date.compare(&1.start_date, timestamp) == :gt))
         |> List.first() do
      nil -> {:error, "#{type} not found for the CDR timestamp"}
      item -> {:ok, item}
    end
  end

  defp validate_changeset(%{valid?: false} = changeset, _acc) do
    {:halt, {:error, changeset}}
  end

  defp validate_changeset(changeset, acc) do
    changeset = CDR.changeset(changeset.changes)

    case Changeset.apply_action(changeset, :insert) do
      {:ok, _cdr} ->
        attrs = CDRex.Changeset.add_timestamps(changeset.changes)

        {:cont, [attrs | acc]}

      {:error, _} = error ->
        {:halt, error}
    end
  end
end
