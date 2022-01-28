# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :cdrex,
  namespace: CDRex,
  ecto_repos: [CDRex.Repo],
  generators: [binary_id: true]

# Database configuration
config :cdrex, CDRex.Repo,
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id],
  migration_timestamps: [type: :utc_datetime_usec]

# Configures the endpoint
config :cdrex, CDRexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TCm5V86XhuFS5M4YTot0ISEvAQCKSE/a8pYsrs+pJDBuIur7UBq8ibyauEGnI70q",
  render_errors: [view: CDRexWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: CDRex.PubSub,
  live_view: [signing_salt: "Tjycjr4A"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
