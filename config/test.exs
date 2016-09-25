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

# config :guardian, Guardian,
#   allowed_algos: ["ES512"],
#   verify_module: Guardian.JWT,
#   issuer: "Spherium",
#   ttl: { 60, :minutes },
#   verify_issuer: true,
#   secret_key: %{
#     "crv" => "P-521",
#     "d" => "axDuTtGavPjnhlfnYAwkHa4qyfz2fdseppXEzmKpQyY0xd3bGpYLEF4ognDpRJm5IRaM31Id2NfEtDFw4iTbDSE",
#     "kty" => "EC",
#     "x" => "AL0H8OvP5NuboUoj8Pb3zpBcDyEJN907wMxrCy7H2062i3IRPF5NQ546jIJU3uQX5KN2QB_Cq6R_SUqyVZSNpIfC",
#     "y" => "ALdxLuo6oKLoQ-xLSkShv_TA0di97I9V92sg1MKFava5hKGST1EKiVQnZMrN3HO8LtLT78SNTgwJSQHAXIUaA-lV"
#   },
#   serializer: Spherium.ArtifactSerializer
