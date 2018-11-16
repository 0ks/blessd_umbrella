use Mix.Config

# Configure your database
config :blessd, Blessd.Repo,
  pool_size: 2,
  url: "${DATABASE_URL}",
  ssl: true,
  database: ""
