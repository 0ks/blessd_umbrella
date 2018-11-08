use Mix.Config

# Configure your database
config :blessd, Blessd.Repo,
  username: "postgres",
  password: "postgres",
  database: "blessd_dev",
  hostname: "localhost",
  pool_size: 10
