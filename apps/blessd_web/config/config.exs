# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :blessd_web,
  namespace: BlessdWeb,
  ecto_repos: [Blessd.Repo]

# Configures the endpoint
config :blessd_web, BlessdWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iru7uCovTBZ11uxNyv0JeqVu/L2t4H4hctBXRRaIVSJmlp/qMsEsU412RSPX1fsw",
  render_errors: [view: BlessdWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BlessdWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :blessd_web, :generators, context_app: :blessd

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
