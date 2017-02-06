defmodule Spherium.Cache do
  @moduledoc """
  Module representing the caching layer of the application.
  """

  use Supervisor

  @type command :: [binary]

  @doc """
  Starts the cache supervisor.
  """
  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  @doc """
  Initializes the cache supervisor.
  """
  def init([]) do
    pool_size = 5

    children = for n <- 1..pool_size do
      worker(Redix, [[], [name: String.to_atom("redix_#{n}")]], id: {Redix, n})
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
    Redix.command(String.to_atom("redix_#{random_index()}"), command, opts)
  end

  @doc """
  Executes a command on a child Redix process, throws on error.
  """
  @spec execute!(command, Keyword.t) ::
    Redix.Protocol.redis_value |
    no_return
  def execute!(command, opts \\ []) do
    Redix.command!(String.to_atom("redix_#{random_index()}"), command, opts)
  end

  defp random_index() do
    rem(System.unique_integer([:positive]), 5) + 1
  end
end
