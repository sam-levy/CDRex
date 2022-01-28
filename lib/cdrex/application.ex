defmodule CDRex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CDRex.Repo,
      CDRexWeb.Telemetry,
      {Phoenix.PubSub, name: CDRex.PubSub},
      CDRexWeb.Endpoint,
      {CDRex.Initializer, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CDRex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CDRexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
