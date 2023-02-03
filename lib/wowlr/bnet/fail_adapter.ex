defmodule Wowlr.Bnet.Failadapter do
  @behaviour Wowlr.Bnet

  @impl true
  def get_spell(_id), do: raise()

  @impl true
  def get_spell_media(_id), do: raise()

  @impl true
  def get_character(_), do: raise()

  defp raise,
    do:
      raise(
        "No Bnet adapter set. Please check your config if `config :wowlr, Wowlr.Bnet, :adapter` is set"
      )
end
