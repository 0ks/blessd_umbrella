use Mix.Config

# Configure your database
config :blessd, Blessd.Repo,
  pool_size: 2,
  url: "${DATABASE_URL}",
  ssl: true,
  database: ""

config :blessd, Blessd.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: {:system, "SENDGRID_API_KEY"}
