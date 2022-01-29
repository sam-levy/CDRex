defmodule CDRex.Factories.CDRFactory do
  defmacro __using__(_opts \\ []) do
    quote do
      alias CDRex.CDRs.CDR

      def factory(:cdr, attrs) do
        number_of_units = number_of_units()

        %CDR{
          client_name: sequence(&"Client_#{&1}"),
          client_code: sequence(&"#{random_string_number()}#{&1}"),
          carrier_name: sequence(&"Carrier_#{&1}"),
          source_number: random_string_number(),
          destination_number: random_string_number(),
          direction: random_direction_type(),
          service: random_service_type(),
          number_of_units: number_of_units,
          success: true,
          timestamp: random_past_naivedatetime(),
          amount: number_of_units * random_rate()
        }
      end

      def number_of_units, do: :rand.uniform(100)
    end
  end
end
