defmodule Wowlr.Logs.LogReader do
  use GenServer

  defstruct timestamp: 0, log_version: 0, advanced: false, version: "0", project_id: 0

  def watch(path) do
    GenServer.call(__MODULE__, {:watch, path})
  end

  def read(time) do
    GenServer.call(__MODULE__, {:read, time})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
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

    {:ok, info} = File.stat(path)
    {:ok, device} = File.open(path, [:read, :utf8])

    timestamp =
      info.ctime
      |> NaiveDateTime.from_erl!()
      |> Timex.to_datetime()

    with {:ok, line} <- :file.read_line(device),
         {:ok, parsed} <- parse(line, timestamp) do
      [log_version, _, advanced, _, version, _, project_id] = parsed.payload

      adv =
        case advanced do
          1 -> true
          _ -> false
        end

      new_state = %{
        state
        | timestamp: timestamp,
          log_version: log_version,
          advanced: adv,
          version: version,
          project_id: project_id
      }

      {:reply, {:ok, new_state}, {device, new_state}}
    else
      {:error, reason} -> {:reply, {:error, reason}, {device, state}}
      {:error, reason, line} -> {:reply, {:error, reason, line}, {device, state}}
    end
  end

  @impl true
  def handle_call({:read, time}, _from, {device, state}) do
    with {:ok, line} <- :file.read_line(device),
         {:ok, parsed} <- parse(line, time) do
      {:reply, {:ok, parsed, line}, {device, state}}
    else
      {:error, reason} -> {:reply, {:error, reason}, {device, state}}
      {:error, reason, line} -> {:reply, {:error, reason, line}, {device, state}}
    end
  end

  defp parse(line, reference_time) do
    case Wowlr.Logs.Parser.parse_line(line, reference_time) do
      {:ok, parsed} ->
        {:ok, parsed}

      {:error, err} ->
        {:error, err, line}

      other ->
        dbg()
        {:error, other}
    end
  end
end
