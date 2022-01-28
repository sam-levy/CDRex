defmodule CDRex.Initializer do
  use Task

  alias CDRex.CarrierRates

  def start_link(_arg) do
    Task.start_link(__MODULE__, :initialize, [])
  end

  def initialize do
    if Mix.env() == :test do
      :ok
    else
      carrier_rates_file_path = Application.app_dir(:cdrex, "priv/assets/buy_rates.csv")
      _client_rates_file_path = Application.app_dir(:cdrex, "priv/assets/sell_rates.csv")

      case CarrierRates.create_from_csv(carrier_rates_file_path) do
        {:ok, _} -> IO.puts("Updated carrier rates from CSV file")
        {:error, message} -> IO.puts(message)
      end
    end
  end
end
