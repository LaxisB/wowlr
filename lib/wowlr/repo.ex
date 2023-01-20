defmodule Wowlr.Repo do
  use Ecto.Repo,
    otp_app: :wowlr,
    adapter: Ecto.Adapters.SQLite3
end
