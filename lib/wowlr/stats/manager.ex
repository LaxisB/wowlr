defmodule Wowlr.Stats.Manager do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def aggregator_creator_middleware(%Wowlr.Eventbus.Event{payload: payload} = event)
      when is_list(payload.payload) do
    case payload.event do
      "COMBATANT_INFO" ->
        agent = hd(payload.payload)
        IO.inspect(GenServer.call(__MODULE__, {:stop_agent, agent}), label: agent)
        GenServer.call(__MODULE__, {:add_agent, agent})
        event

      _ ->
        event
    end
  end

  def get_state(agent) do
    GenServer.call(__MODULE__, {:get_state, agent})
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  def aggregator_creator_middleware(event), do: event

  @impl true
  def init(_) do
    {:ok, Map.new()}
  end

  @impl true
  def handle_call({:add_agent, agent}, _, state) do
    case Wowlr.Stats.Aggregator.start_link(agent) do
      {:ok, pid} -> {:reply, {:ok, pid}, Map.put(state, agent, pid)}
      {:ok, pid, _} -> {:reply, {:ok, pid}, Map.put(state, agent, pid)}
      _ -> {:reply, {:error, :already_started}, state}
    end
  end

  @impl true
  def handle_call({:know_agent, agent}, _, state) do
    {:reply, Map.has_key?(state, agent), state}
  end

  @impl true
  def handle_call({:stop_agent, agent}, _, state) do
    with {:ok, pid} <- Map.fetch(state, agent),
         agent_state <- GenServer.call(pid, :get_state) do
      GenServer.stop(pid, :normal)
      {:reply, agent_state, state}
    else
      _ -> {:reply, nil, state}
    end
  end

  @impl true
  def handle_call({:get_state, agent}, _from, state) do
    Map.get(state, agent)
    |> Wowlr.Stats.Aggregator.get_state()
    |> then(&{:reply, &1, state})
  end
end
