use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :spherium, Spherium.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :spherium, Spherium.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "main",
  password: "kuz60TOL12",
  database: "ExSWS_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure Bcrypt library
config :comeonin,
  bcrpyt_log_rounds: 4
