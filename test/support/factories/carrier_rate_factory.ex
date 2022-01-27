defmodule CDRex.Factories.CarrierRateFactory do
  defmacro __using__(_opts \\ []) do
    quote do
      alias CDRex.CarrierRates.CarrierRate

      def factory(:carrier_rate, attrs) do
        %CarrierRate{
          carrier_name: sequence(&"Carrier_#{&1}"),
          start_date: random_past_date(),
          rate: random_rate(),
          service: random_service_type(),
          direction: random_direction_type()
        }
      end
    end
  end
end
