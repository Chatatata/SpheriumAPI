defmodule Spherium.Cache do
  @moduledoc """
  Module representing the caching layer of the application.
  """

  use Supervisor

  @type command :: [binary]

  @otp_app :spherium
  @default_pool_size 8

  @doc """
  Starts the cache supervisor.
  """
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: Spherium.Cache)
  end

  @doc """
  Initializes the cache supervisor.
  """
  def init(_) do
    config = Application.get_env(@otp_app, Spherium.Cache, [])
    pool_size = config[:pool_size] || @default_pool_size
    database = config[:database] || nil
    password = config[:password] || nil
    hostname = config[:host] || "localhost"

    children = for n <- 1..pool_size do
      worker(Redix,
             [[host: hostname, database: database, password: password],
              [name: String.to_atom("Redix.Worker.#{n}")]],
             id: {Redix, n})
    end

    supervise(children, strategy: :one_for_one)
  end

  @doc """
  Executes a command on a child Redix process.
  """
  @spec execute(command, Keyword.t) ::
    {:ok, Redix.Protocol.redis_value} |
    {:error, atom | Redix.Error.t}
  def execute(command, opts \\ []) do
    worker = opts[:worker] || random_index()

    Redix.command(String.to_atom("Redix.Worker.#{worker}"), command, opts)
  end

  @doc """
  Executes a command on a child Redix process, throws on error.
  """
  @spec execute!(command, Keyword.t) ::
    Redix.Protocol.redis_value |
    no_return
  def execute!(command, opts \\ []) do
    worker = opts[:worker] || random_index()

    Redix.command!(String.to_atom("Redix.Worker.#{worker}"), command, opts)
  end

  defp random_index() do
    config = Application.get_env(@otp_app, Spherium.Cache, [])
    pool_size = config[:pool_size] || @default_pool_size

    rem(System.unique_integer([:positive]), pool_size) + 1
  end
end
