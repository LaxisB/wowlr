defmodule Wowlr.Bnet.TestAdapter do
  @behaviour Wowlr.Bnet

  @impl true
  def get_spell(id), do: %{id: id}
  @impl true
  def get_spell_media(id), do: %{id: id}

  @impl true
  def get_character({name, realm, region}), do: %{name: name, realm: realm, region: region}
end
