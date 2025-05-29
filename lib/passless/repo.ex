defmodule Passless.Repo do
  use Ecto.Repo,
    otp_app: :passless,
    adapter: Ecto.Adapters.Postgres
end
