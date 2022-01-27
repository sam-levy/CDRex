defmodule CDRex.Factories.ClientRateFactory do
  defmacro __using__(_opts \\ []) do
    quote do
      alias CDRex.ClientRates.ClientRate

      def factory(:client_rate, attrs) do
        %ClientRate{
          client_code: sequence(&"#{random_string_number()}#{&1}"),
          start_date: random_past_date(),
          rate: random_rate(),
          service: random_service_type(),
          direction: random_direction_type()
        }
      end
    end
  end
end
