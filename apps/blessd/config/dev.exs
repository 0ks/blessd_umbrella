use Mix.Config

# Configure your database
config :blessd, Blessd.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "blessd_dev",
  hostname: "localhost",
  pool_size: 10
