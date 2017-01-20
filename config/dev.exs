use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :spherium, Spherium.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Comeonin hashing algorithms round quantities
config :comeonin,
  bcrypt_log_rounds: 4,
  pbkdf2_rounds: 1_000

config :mix_test_watch,
  clear: true

# Configure your database
config :spherium, Spherium.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "main",
  password: "kuz60TOL12",
  database: "ExSWS_dev",
  hostname: "localhost",
  pool_size: 10
