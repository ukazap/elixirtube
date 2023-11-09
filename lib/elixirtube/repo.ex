defmodule Elixirtube.Repo do
  use Ecto.Repo,
    otp_app: :elixirtube,
    adapter: Ecto.Adapters.Postgres
end
