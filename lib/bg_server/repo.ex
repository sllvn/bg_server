defmodule BgServer.Repo do
  use Ecto.Repo,
    otp_app: :bg_server,
    adapter: Ecto.Adapters.Postgres
end
