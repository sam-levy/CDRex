defmodule CDRexWeb.Router do
  use CDRexWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", CDRexWeb.Api.V1 do
    pipe_through :api

    post "/cdrs", CDRController, :create
    get "/cdrs/client_summary_by_month", CDRController, :client_summary_by_month
  end

  # Enables LiveDashboard only for development
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: CDRexWeb.Telemetry
    end
  end
end
