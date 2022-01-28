defmodule CDRex.Changeset do
  # TODO: Add tests
  def add_timestamps(%{} = attrs) do
    now = DateTime.utc_now()

    attrs
    |> Map.put(:inserted_at, now)
    |> Map.put(:updated_at, now)
  end
end
