# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :passless,
  ecto_repos: [Passless.Repo],
  generators: [timestamp_type: :utc_datetime],
  guardian_secret_key: System.get_env("GUARDIAN_SECRET_KEY") || "secret_key_to_be_changed_in_prod"

# Guardian configuration
config :passless, PasslessWeb.Auth.Guardian,
  issuer: "passless",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY") || "secret_key_to_be_changed_in_prod",
  ttl: {30, :days}

# Configures the endpoint
config :passless, PasslessWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: PasslessWeb.ErrorHTML, json: PasslessWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Passless.PubSub,
  live_view: [signing_salt: "k+24fgTa"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :passless, Passless.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  passless: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  passless: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# OTP configuration
config :passless, :otp,
  # 5 minutes
  expiry_seconds: 300,
  otp_length: 6

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Phoenix Swagger configuration
config :passless, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: PasslessWeb.Router,
      endpoint: PasslessWeb.Endpoint
    ]
  }

config :passless, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [router: PasslessWeb.Router]
  }

config :phoenix_swagger, json_library: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
