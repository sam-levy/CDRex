defmodule CDRex.CDRs do
  alias CDRex.CDRs.Creator
  # alias CDRex.Repo

  defdelegate create(attrs, opts \\ []), to: Creator
  defdelegate create_from_csv(csv_file_path), to: Creator
end
