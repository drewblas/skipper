use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :skipper, Skipper.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :skipper, Skipper.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "skipper_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  size: 1 # Use a single connection for transactional tests
