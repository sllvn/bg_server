import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bg_server, BgServerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "jdb9NmskIddza0YBzb1cZa03Xpqit7WFcwRp6G/cl7Rmm/mYf20sUV998l593yri",
  server: false

# In test we don't send emails.
config :bg_server, BgServer.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
