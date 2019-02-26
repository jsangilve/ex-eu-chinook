use Mix.Config

config :chinook,
  ecto_repos: [Chinook.Repo]

import_config "#{Mix.env()}.exs"
