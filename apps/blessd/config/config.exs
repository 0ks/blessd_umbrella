use Mix.Config

config :blessd, ecto_repos: [Blessd.Repo]

import_config "#{Mix.env()}.exs"
