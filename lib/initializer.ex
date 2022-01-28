defmodule CDRex.Initializer do
  use Task

  def start_link(_arg) do
    Task.start_link(__MODULE__, :initialize, [])
  end

  def initialize do
    if Mix.env() == :test do
      :ok
    else
      carrier_rates_file_path = Application.app_dir(:cdrex, "priv/assets/buy_rates.csv")
      client_fees_file_path = Application.app_dir(:cdrex, "priv/assets/sell_rates.csv")

      case CDRex.CarrierRates.create_from_csv(carrier_rates_file_path) do
        {:ok, _} -> IO.puts("Updated carrier rates from CSV file")
        {:error, message} -> IO.puts("carrier rates: " <> message)
      end

      case CDRex.ClientFees.create_from_csv(client_fees_file_path) do
        {:ok, _} -> IO.puts("Updated client fees from CSV file")
        {:error, message} -> IO.puts("client fees: " <> message)
      end
    end
  end
end
