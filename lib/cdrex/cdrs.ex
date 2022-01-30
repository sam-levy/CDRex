defmodule CDRex.CDRs do
  @moduledoc """
    The CDRs context.
  """

  alias CDRex.CDRs.{Creator, Reporter}

  defdelegate create(attrs, opts \\ []), to: Creator
  defdelegate create_from_csv(csv_file_path), to: Creator

  defdelegate client_summary_by_month(client_code, month, year), to: Reporter
end
