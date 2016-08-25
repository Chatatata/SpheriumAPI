ExUnit.start

Mix.Task.run "ecto.create", ~w(-r SpheriumWebService.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r SpheriumWebService.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(SpheriumWebService.Repo)

