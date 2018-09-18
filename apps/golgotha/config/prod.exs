use Mix.Config

# Configure your database
config :golgotha, Golgotha.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true,
  database: "golgotha_prod",
  url: System.get_env("DATABASE_URL")
