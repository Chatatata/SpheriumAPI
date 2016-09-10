# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SpheriumWebService.Repo.insert!(%SpheriumWebService.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias SpheriumWebService.Repo
alias SpheriumWebService.User

Repo.delete_all(User)
User.changeset(%User{}, %{username: "test", password: "test", email: "test@mail.com"}) |> Repo.insert!()
User.changeset(%User{}, %{username: "another_test", password: "test", email: "another_test@mail.com"}) |> Repo.insert!()
