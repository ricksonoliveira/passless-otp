defmodule Passless.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      Passless.Repo,

      # Start our custom Cache wrapper which uses ETS
      Passless.Cache,

      # Start the PubSub system
      {Phoenix.PubSub, name: Passless.PubSub},

      # Start the Finch HTTP client for sending emails
      {Finch, name: Passless.Finch},

      # Start the Telemetry supervisor
      PasslessWeb.Telemetry,

      # Start DNS cluster for distributed deployments
      {DNSCluster, query: Application.get_env(:passless, :dns_cluster_query) || :ignore},

      # Start the endpoint when the application starts
      PasslessWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Passless.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PasslessWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Configuration is handled in config/config.exs
end
