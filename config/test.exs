use Mix.Config

config :chinook, Chinook.Repo,
  database: "chinook",
  username: "jsangil",
  password: "test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
