defmodule Wowlr.Logs do
  use DynamicSupervisor

  @impl DynamicSupervisor
  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl DynamicSupervisor
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def watch_file(path) do
    Wowlr.Logs.LogReader.watch(path)
  end

  def test() do
    Wowlr.Logs.Parser.line(
      "1/5 16:43:45.443  COMBAT_LOG_VERSION,20,ADVANCED_LOG_ENABLED,1,BUILD_VERSION,10.0.2,PROJECT_ID,1\n"
    )
  end
end
