defmodule CDRex.Repo do
  use Ecto.Repo,
    otp_app: :cdrex,
    adapter: Ecto.Adapters.Postgres
end
