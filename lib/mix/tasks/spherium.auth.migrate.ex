defmodule Mix.Tasks.Spherium.Auth.Migrate do
  use Mix.Task

  alias SpheriumWebService.Repo
  alias SpheriumWebService.Permission

  import Ecto.Query
  import Mix.Ecto

  @shortdoc "Refreshes authorization permissions"

  def run(_) do
    {:ok, pid, _apps} = ensure_started(Repo, [])
    sandbox? = Repo.config[:pool] == Ecto.Adapters.SQL.Sandbox

    # If the pool is Ecto.Adapters.SQL.Sandbox,
    # let's make sure we get a connection outside of a sandbox.
    if sandbox? do
      Ecto.Adapters.SQL.Sandbox.checkin(Repo)
      Ecto.Adapters.SQL.Sandbox.checkout(Repo, sandbox: false)
    end

    Module.concat(Mix.Phoenix.base(), "Router").__routes__
    |> Enum.filter(&(Enum.member?(&1.pipe_through, :api)))
    |> Enum.map(&permissions_from_router/1)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.reduce({0, 0}, &(counter(persist(&1), &2)))
    |> format_result()

    sandbox? && Ecto.Adapters.SQL.Sandbox.checkin(Repo)

    pid && Repo.stop(pid)
  end

  defp permissions_from_router(router) do
    cap = [permission_from_router_with_type(router, "all")]

    case router.opts do
      :index -> cap
      _ -> [permission_from_router_with_type(router, "one") | cap]
    end
  end

  defp permission_from_router_with_type(router = %Phoenix.Router.Route{}, type) when is_binary(type) do
    %Permission{required_grant_power: 200,
                controller_name: Atom.to_string(router.plug),
                controller_action: Atom.to_string(router.opts),
                type: type}
  end

  defp persist(permission) do
    query = from p in Permission,
            where: p.controller_name == ^permission.controller_name and
                   p.controller_action == ^permission.controller_action and
                   p.type == ^permission.type

    case Repo.one(query, log: false) do
      nil -> not is_nil(Repo.insert!(permission, log: false))
      _ -> false
    end
  end

  defp counter(boolean, {truthy, falsey}) do
    case boolean do
      true -> {truthy + 1, falsey}
      false -> {truthy, falsey + 1}
    end
  end

  defp format_result({truthy, falsey}) do
    if truthy > 0 do
      IO.puts "#{truthy + falsey} permissions at total, #{truthy} inserted."
    else
      IO.puts "#{truthy + falsey} permissions at total, all permissions up-to-date."
    end
  end
end
