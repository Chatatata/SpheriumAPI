# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :spherium_web_service, SpheriumWebService.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "jgnCnfGSLRc78owP6DkUXyp4y4X10TxIpHsFNaEylod8/b26x4RQTi3NOVd9OcZp",
  render_errors: [accepts: ~w(json)],
  pubsub: [name: SpheriumWebService.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :spherium_web_service, ecto_repos: [SpheriumWebService.Repo]
