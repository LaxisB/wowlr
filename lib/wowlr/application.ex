defmodule Wowlr.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Wowlr.Repo,
      {Task, &Wowlr.MigrationHelpers.migrate/0},
      Wowlr.Config,
      Wowlr.Eventbus.Supervisor,
      Wowlr.Logs.LogReader,
      Wowlr.Stats.Manager,
      WowlrWeb.Telemetry,
      {DynamicSupervisor, name: Wowlr.Stats.Supervisor},
      {Phoenix.PubSub, name: Wowlr.PubSub},
      WowlrWeb.Endpoint,
      {Finch, name: MyFinch}
    ]

    opts = [strategy: :one_for_one, name: Wowlr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    WowlrWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
