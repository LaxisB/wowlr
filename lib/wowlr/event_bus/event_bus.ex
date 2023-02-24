defmodule Wowlr.Eventbus do
  use GenServer

  defstruct topics: MapSet.new(), middlewares: []

  alias Wowlr.Eventbus.Event

  ## public API
  @spec create_topic(binary()) :: {:ok} | {:error, binary()}
  def create_topic(name) do
    GenServer.call(__MODULE__, {:create_topic, name})
  end

  def delete_topic(name) do
    GenServer.call(__MODULE__, {:delete_topic, name})
  end

  def publish(%Event{} = event, topic) do
    GenServer.call(__MODULE__, {:publish, event, topic})
  end

  def subscribe(topic, routing_key \\ nil) do
    Registry.register(Wowlr.Eventbus.Registry, topic, routing_key)
  end

  def unsubscribe_all(topic) do
    Registry.unregister(Wowlr.Eventbus.Registry, topic)
  end

  def unsubscribe(topic, routing_key) do
    Registry.unregister_match(Wowlr.Eventbus.Registry, topic, routing_key)
  end

  def get_event({id, topic}) do
    case :ets.lookup(topic, id) do
      [{key, event}] -> {:ok, event}
      _ -> {:error, "no such event"}
    end
  end

  def drop_events(topic) do
    :ets.delete_all_objects(topic)
  end

  def add_middleware(callback, topic) do
    GenServer.cast(__MODULE__, {:add_middleware, callback, topic})
  end

  ## Callbacks

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_) do
    middlewares = [
      {{Wowlr.Stats.Manager, :aggregator_creator_middleware}, :event_read}
    ]

    {:ok, %__MODULE__{middlewares: middlewares}}
  end

  @impl true
  def handle_call({:create_topic, topic}, _, state) do
    topic_name = as_topic_name(topic)

    case :ets.whereis(topic_name) do
      :undefined ->
        table = :ets.new(topic_name, [:set, :named_table])
        state = %{state | topics: MapSet.put(state.topics, topic)}
        {:reply, table, state}

      _ ->
        {:reply, {:error, "duplicate topic"}, state}
    end
  end

  @impl true
  def handle_call({:delete_topic, topic}, _, state) do
    topic_name = as_topic_name(topic)

    case :ets.whereis(topic_name) do
      :undefined ->
        {:reply, :ok, state}

      _ ->
        :ets.delete(topic_name)
        Registry.unregister(Wowlr.Eventbus.Registry, topic_name)
        state = %{state | topics: MapSet.delete(state.topics, topic)}
        {:reply, :ok, MapSet.delete(state, state)}
    end
  end

  @impl true
  def handle_call({:publish, event, topic}, _, state) do
    with topic_name <- as_topic_name(topic),
         event <- apply_middlewares(topic, event, state.middlewares),
         state <- ensure_topic_exists(state, topic),
         :ok <- store(topic_name, event) do
      Registry.dispatch(
        Wowlr.Eventbus.Registry,
        topic,
        &dispatch(&1, topic, event)
      )

      Process.send_after(self(), {:delete_event, event.id, topic_name}, 5_000)

      {:reply, :ok, state}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
      _ -> {:reply, {:error, "uncaught"}, state}
    end
  end

  @impl true
  def handle_cast({:add_middleware, callback, topic}, state) do
    {:noreply, %{state | middlewares: [{callback, topic} | state.middlewares]}}
  end

  def handle_info({:delete_event, event, topic}, state) do
    :ets.delete(topic, event)
    {:noreply, state}
  end

  ## helpers

  defp as_topic_name(key) when is_binary(key) do
    ("topic-" <> key)
    |> String.to_atom()
  end

  defp as_topic_name(key) when is_atom(key) do
    as_topic_name(Atom.to_string(key))
  end

  defp dispatch(listeners, topic, event) do
    shadow = {event.id, as_topic_name(topic)}

    for {pid, routing} <- listeners do
      if routing == event.routing_key do
        send(pid, {topic, shadow})
      end
    end
  end

  defp ensure_topic_exists(state, topic) do
    topic_name = as_topic_name(topic)

    case(MapSet.member?(state.topics, topic)) do
      true ->
        state

      false ->
        :ets.new(topic_name, [:set, :named_table])
        %{state | topics: MapSet.put(state.topics, topic)}
    end
  end

  defp store(topic_name, %Wowlr.Eventbus.Event{} = event) do
    case :ets.insert(topic_name, {event.id, event}) do
      true -> :ok
      _ -> :error
    end
  end

  defp store(topic_name, _), do: :error

  defp apply_middlewares(_, nil, _), do: :ok
  defp apply_middlewares(_topic, event, []), do: event

  defp apply_middlewares(topic, event, [{cb, wanted_topic} | tail]) do
    new_event =
      if wanted_topic == topic do
        {module, func} = cb
        apply(module, func, [event])
      end

    case new_event do
      nil -> nil
      e -> apply_middlewares(topic, e, tail)
    end
  end
end
