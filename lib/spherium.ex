defmodule Spherium do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Spherium.Endpoint, []),
      # Start the Ecto repository
      supervisor(Spherium.Repo, []),
      # Start the Redix as a worker
      worker(Redix, [[], [name: :redix]])
    ]

    pool_size = 5
    redix_workers = for i <- 0..(pool_size - 1) do
      worker(Redix, [[], [name: :"redix_#{i}"]], id: {Redix, i})
    end

    children = Enum.concat(children, redix_workers)

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spherium.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Spherium.Endpoint.config_change(changed, removed)
    :ok
  end
end
