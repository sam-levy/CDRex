defmodule CDRexWeb.Router do
  use CDRexWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", CDRexWeb.Api.V1 do
    pipe_through :api

    post "/cdrs", CDRController, :create
    post "/cdrs/import", CDRController, :import
    get "/cdrs/client_summary_by_month", CDRController, :client_summary_by_month
  end
end
