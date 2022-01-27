defmodule CDRex.Factory do
  use CDRex.Factories.ClientRateFactory
  use CDRex.Factories.CarrierRateFactory
  use CDRex.Factories.CDRFactory

  def build(factory_name, attributes \\ []) do
    factory_name |> factory(attributes) |> struct(attributes)
  end

  def insert(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> CDRex.Repo.insert!()
  end

  def build_list(amount, factory_name, attributes \\ []) do
    Stream.repeatedly(fn -> build(factory_name, attributes) end) |> Enum.take(amount)
  end

  def insert_list(amount, factory_name, attributes \\ []) do
    Stream.repeatedly(fn -> insert(factory_name, attributes) end) |> Enum.take(amount)
  end

  # def factory(factory_name, _attributes), do: factory(factory_name)

  def random_enum_value(enum), do: Enum.random(enum.__enums__())

  def random_number, do: :rand.uniform(10_000)

  def random_string_number, do: random_number() |> to_string()

  def random_past_date, do: Date.utc_today() |> Date.add(random_number() * -1)

  def truncated_naivedatetime do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  end

  def random_past_naivedatetime do
    truncated_naivedatetime() |> NaiveDateTime.add(random_number() * -1)
  end

  defp sequence(fun) when is_function(fun, 1) do
    fun.(System.unique_integer([:positive, :monotonic]))
  end

  def random_service_type, do: random_enum_value(CDRex.Enums.ServiceType)

  def random_direction_type, do: random_enum_value(CDRex.Enums.DirectionType)

  def random_rate(), do: (:rand.uniform() * 0.1) |> Float.round(4)
end
