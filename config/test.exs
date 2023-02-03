import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :wowlr, Wowlr.Repo,
  database: Path.expand("../wowlr_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :wowlr, WowlrWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ltKK8RaYe4n/SoO4jQpo0QYLsgdR1meYad/HE00nTnPAANmOlEZ8J9pFDejJ4BIS",
  server: false

config :wowlr, Wowlr.Bnet, adapter: Wowlr.Bnet.TestAdapter

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
