use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :blessd_web, BlessdWeb.Endpoint,
  http: [port: 4001],
  server: false

config :blessd_web, BlessdWeb.Mailer, adapter: Bamboo.TestAdapter

