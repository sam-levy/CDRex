defmodule CDRex.Factories.ClientFeeFactory do
  defmacro __using__(_opts \\ []) do
    quote do
      alias CDRex.ClientFees.ClientFee

      def factory(:client_fee, attrs) do
        %ClientFee{
          client_code: sequence(&"#{random_string_number()}#{&1}"),
          start_date: random_past_date(),
          fee: random_rate(),
          service: random_service_type(),
          direction: random_direction_type()
        }
      end
    end
  end
end
