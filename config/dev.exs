use Mix.Config

# low privileges 
# config :chinook, Chinook.Repo,
#  database: "chinook",
#  username: "chinook_low",
#  password: "test_low",
#  hostname: "localhost"

config :chinook, Chinook.Repo,
  database: "chinook",
  username: "chinook_app",
  password: "test",
  hostname: "localhost"
