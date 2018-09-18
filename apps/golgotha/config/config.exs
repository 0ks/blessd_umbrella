use Mix.Config

config :golgotha, ecto_repos: [Golgotha.Repo]

import_config "#{Mix.env()}.exs"
