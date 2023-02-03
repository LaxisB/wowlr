defmodule Wowlr.Logs.LogReader do
  use GenServer

  defstruct timestamp: 0, log_version: 0, advanced: false, version: "0", project_id: 0

  def watch(path) do
    GenServer.call(__MODULE__, {:watch, path})
  end

  def read() do
    GenServer.call(__MODULE__, :read)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  defp parse_next_line(device) do
    with {:ok, line} <- :file.read_line(device),
         {:ok, parsed, _, _, _, _} <- Wowlr.Logs.Parser.line(line) do
      {:ok, parsed}
    else
      {:error, reason} -> {:error, reason}
      :eof -> {:error, :eof}
      other -> {:error, other}
    end

  end

  @impl true
  def init(_) do
    {:ok, {nil, %__MODULE__{timestamp: nil, advanced: false, version: "0.0.0"}}}
  end


  @impl true
  def handle_call({:watch, path}, _from, {device, state}) do
    if device do
      File.close(device)
    end
    {:ok, device} = File.open(path, [:read, :utf8])

    with {:ok, line} <- parse_next_line(device) do
        [timestamp, "COMBAT_LOG_VERSION", log_version, _, advanced, _, version, _, project_id] = line
        adv = case advanced do
          1 -> true
          _ -> false
        end
        new_state = %{state | timestamp: timestamp, log_version: log_version, advanced: adv, version: version, project_id: project_id}
       {:reply, {:ok, new_state}, {device, new_state}}
    else
      {:error, reason} -> {:reply, {:error, reason}, {device, state}}
    end
  end

  @impl true
  def handle_call(:read, _from, device) do
    case parse_next_line(device) do
      {:ok, line} -> {:reply, {:ok, line}, device}
      {:error, reason} -> {:reply, {:error, reason}, device}
    end
  end
end
