use Mix.Config

# Configure your database
config :blessd, Blessd.Repo,
  username: System.get_env("PG_USERNAME") || "postgres",
  password: System.get_env("PG_PASSWORD") || "postgres",
  hostname: System.get_env("PG_HOST") || "localhost",
  database: System.get_env("DATABASE_NAME") || "blessd_test",
  ownership_timeout: 10 * 60 * 1000,
  pool: Ecto.Adapters.SQL.Sandbox

config :blessd, Blessd.Mailer, adapter: Bamboo.TestAdapter

config :bcrypt_elixir, log_rounds: 1
