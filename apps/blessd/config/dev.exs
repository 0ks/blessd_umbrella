use Mix.Config

# Configure your database
config :blessd, Blessd.Repo,
  username: "postgres",
  password: "postgres",
  database: "blessd_dev",
  hostname: "localhost",
  pool_size: 10

config :blessd, Blessd.Mailer,
  adapter: Bamboo.LocalAdapter,
  open_email_in_browser_url: "http://localhost:4000/sent_emails"
