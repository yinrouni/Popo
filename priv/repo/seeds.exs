# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Popo.Repo.insert!(%Popo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Popo.Users.User
alias Popo.Repo

# alias Popo.F

Repo.insert!(%User{email: "aa@aa", name: "aa", password: "123456789012"})
Repo.insert!(%User{email: "bb@bb", name: "bb", password: "123456789012"})

