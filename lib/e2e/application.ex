defmodule E2e.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      if Application.get_env(:corex_web, :start_services, true) do
        [
          E2eWeb.Telemetry,
          E2e.Repo,
          {DNSCluster, query: Application.get_env(:corex_web, :dns_cluster_query) || :ignore},
          {Phoenix.PubSub, name: E2e.PubSub},
          E2eWeb.Endpoint
        ]
      else
        []
      end

    opts = [strategy: :one_for_one, name: E2e.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    if Application.get_env(:corex_web, :start_services, true) do
      E2eWeb.Endpoint.config_change(changed, removed)
    end

    :ok
  end
end
