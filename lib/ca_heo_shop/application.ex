defmodule CaHeoShop.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CaHeoShopWeb.Telemetry,
      CaHeoShop.Repo,
      {DNSCluster, query: Application.get_env(:ca_heo_shop, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CaHeoShop.PubSub},
      # Start a worker by calling: CaHeoShop.Worker.start_link(arg)
      # {CaHeoShop.Worker, arg},
      # Start to serve requests, typically the last entry
      CaHeoShopWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CaHeoShop.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CaHeoShopWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
