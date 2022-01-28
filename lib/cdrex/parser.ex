defmodule CDRex.Parser do
  @moduledoc """
  """

  alias NimbleCSV.RFC4180, as: CSV

  @error {:error, "malformed csv file"}

  def parse_csv_with_headers(csv_file_path) when is_binary(csv_file_path) do
    csv_file_path
    |> File.read!()
    |> CSV.parse_string(skip_headers: false)
    |> build_attrs_map()
    |> case do
      {:error, _} = error -> error
      return when is_list(return) -> {:ok, return}
    end
  end

  defp build_attrs_map([]), do: {:error, "empty file"}

  defp build_attrs_map([_headers | []]), do: {:error, "empty file"}

  defp build_attrs_map([headers | content]) do
    indexed_headers =
      headers
      |> Enum.with_index(fn el, i -> {i, el} end)
      |> Map.new()

    Enum.reduce_while(content, [], &handle_line(&1, &2, indexed_headers))
  end

  defp handle_line(line, acc, indexed_headers) do
    with true <- Enum.count(line) == Enum.count(indexed_headers),
         indexed_line <- Enum.with_index(line),
         %{} = attrs_map <-
           Enum.reduce_while(indexed_line, %{}, &handle_value(&1, &2, indexed_headers)) do
      {:cont, [attrs_map | acc]}
    else
      _ -> {:halt, @error}
    end
  end

  defp handle_value({value, index}, acc, indexed_headers) do
    case Map.get(indexed_headers, index, :not_found) do
      :not_found -> {:halt, @error}
      header -> {:cont, Map.put(acc, header, value)}
    end
  end
end
