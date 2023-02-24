defmodule Wowlr.Logs.LogReader do
  use GenServer
  alias Wowlr.Eventbus

  defstruct reference_time: nil, path: "", read_count: 0

  def watch(path) do
    GenServer.cast(__MODULE__, {:watch, path})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Eventbus.create_topic(:file_changed)
    Eventbus.create_topic(:file_drained)
    Eventbus.create_topic(:event_read)
    {:ok, {nil, %__MODULE__{}}}
  end

  @impl true
  def handle_cast({:watch, path}, {device, state}) do
    if device do
      File.close(device)
    end

    Wowlr.Logs.handle_filechange(path)

    {:ok, info} = File.stat(path)
    # passing :utf8 explodes
    {:ok, device} = File.open(path, [:read])

    timestamp =
      info.ctime
      |> NaiveDateTime.from_erl!()
      |> Timex.to_datetime()

    new_state = %__MODULE__{
      reference_time: timestamp,
      path: path,
      read_count: 0
    }

    Process.send_after(self(), :read_loop, 200)
    {:noreply, {device, new_state}}
  end

  @impl true
  def handle_info(:read_loop, {device, state}) do
    case read_until_empty({device, state}) do
      {:ok, {_, new_state}} ->
        sleep_time =
          case state.read_count == new_state.read_count do
            true -> 1000
            false -> 200
          end

        Process.send_after(self(), :read_loop, sleep_time)
        {:noreply, {device, new_state}}

      {:error, reason} ->
        {:noreply, state}
    end
  end

  defp read_until_empty({device, state}) do
    with {:ok, line} <- :file.read_line(device),
         {:ok, parsed} <- Wowlr.Logs.Parser.parse_line(line, state.reference_time) do
      Wowlr.Logs.handle_event(parsed)

      read_until_empty({device, %{state | read_count: state.read_count + 1}})
    else
      :eof ->
        Wowlr.Logs.handle_drained(state.path)
        {:ok, {device, state}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
