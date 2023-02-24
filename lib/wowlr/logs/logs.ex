defmodule Wowlr.Logs do
  alias Wowlr.Eventbus

  def read_file(filename) do
    file_path =
      Path.join([Wowlr.Config.game_dir(), "Logs", filename])
      |> String.replace(~r"/", "\\")

    Wowlr.Logs.LogReader.watch(file_path)
  end

  def test() do
    Wowlr.Logs.LogReader.watch(
      # "D:\\Games\\World of Warcraft\\_retail_\\Logs\\WoWCombatLog-022223_184848.txt"
      "D:\\Games\\World of Warcraft\\_retail_\\Logs\\WoWCombatLog-022023_200153.txt"
    )
  end

  def get_state() do
    Wowlr.Stats.Manager.get_state("Player-3686-0746ACAD")
  end

  def handle_drained(path) do
    IO.puts("file drained")

    Eventbus.Event.new(path)
    |> Eventbus.publish(:file_drained)
  end

  def handle_filechange(path) do
    Eventbus.Event.new(path)
    |> Eventbus.publish(:file_changed)
  end

  def handle_event(parsed) do
    Eventbus.Event.new(parsed, hd(parsed.payload))
    |> Eventbus.publish(:event_read)
  end
end
