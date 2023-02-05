defmodule Wowlr.Logs.Parser.Event do
  defstruct timestamp: 0, event: "", payload: []

  def from_raw(timestamp, event, payload) do
    %__MODULE__{
      timestamp: timestamp,
      event: event,
      payload: payload
    }
  end
end
