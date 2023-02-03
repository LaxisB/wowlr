defmodule Wowlr.Bnet do
  @moduledoc """
  API for interacting with the Battle.net Api (specifically for WoW)
  check out these links for docs:
   - https://develop.battle.net/documentation/battle-net/oauth-apis
   - https://develop.battle.net/documentation/world-of-warcraft/game-data-apis
  """
  @on_definition Wowlr.SpecToCallback

  alias Wowlr.Bnet

  defdelegate authorize, to: Bnet.Auth

  @spec get_spell(String.t()) :: Map.t()
  def get_spell(id), do: impl().get_spell(id)

  @spec get_spell_media(String.t()) :: Map.t()
  def get_spell_media(id), do: impl().get_spell(id)

  @spec get_character({String.t(), String.t(), String.t()}) :: Map.t()
  def get_character(args), do: impl().get_character(args)

  # get the active adapter (or fail otherwise)
  defp impl do
    config = Application.get_env(:wowlr, Wowlr.Bnet)
    config[:adapter] || Bnet.FailAdapter
  end
end
