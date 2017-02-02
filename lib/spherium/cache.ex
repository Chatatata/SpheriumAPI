defmodule Spherium.Cache do
  def execute(command) do
    Redix.command(:"redix_#{random_index()}", command)
  end

  def execute!(command) do
    Redix.command!(:"redix_#{random_index()}", command)
  end

  defp random_index() do
    rem(System.unique_integer([:positive]), 5)
  end
end
