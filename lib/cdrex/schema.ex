defmodule CDRex.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
      import EctoEnum

      @primary_key {:id, :binary_id, []}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end