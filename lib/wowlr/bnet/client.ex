defmodule Wowlr.Bnet.Client do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(opts) do
  end
end
