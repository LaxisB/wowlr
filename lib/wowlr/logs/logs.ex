defmodule Wowlr.Logs do
  use DynamicSupervisor

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def watch_file(path) do
    Wowlr.Logs.LogReader.watch(path)
  end

  def test() do
    {:ok, header} =
      Wowlr.Logs.LogReader.watch(
        "D:\\Games\\World of Warcraft\\_retail_\\Logs\\WoWCombatLog-020423_194934.txt"
      )

    IO.inspect(header, label: "header")
    read(2, header.timestamp)
  end

  def read(0, _), do: :ok

  def read(num, reference_time) when is_number(num) do
    case Wowlr.Logs.LogReader.read(reference_time) do
      {:ok, parsed, line} ->
        IO.inspect(parsed, label: "parsed")
        read(num - 1, reference_time)

      {:error, err, line} ->
        IO.inspect(line, label: err)
    end
  end
end
