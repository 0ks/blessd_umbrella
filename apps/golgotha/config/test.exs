use Mix.Config

# Configure your database
config :golgotha, Golgotha.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "golgotha_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
