defmodule Wowlr.Eventbus.Event do
  defstruct id: nil, payload: nil, routing_key: nil

  def new(payload), do: new(payload, nil)

  def new(payload, routing_key) do
    %__MODULE__{
      id: UUID.uuid4(),
      payload: payload,
      routing_key: routing_key
    }
  end
end
