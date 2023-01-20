defmodule Wowlr.Bnet.Static do
  import Wowlr.Bnet, only: [base_url: 0, get_auth_header: 0, unwrap_response: 1]

  def build_query(opts \\ %{}) do
    Wowlr.Bnet.build_query(Map.put(opts, :namespace, "static"))
  end

  defp req(url) do
    Finch.build(:get, base_url() <> url, get_auth_header())
    |> Finch.request(MyFinch)
    |> unwrap_response()
  end

  def get_classes()
    req("/data/wow/playable-class/index?#{build_query()}")
  end
  def get_class(id)
    req("/data/wow/playable-class/#{id}?#{build_query()}")
  end
  def get_specs()
    req("/data/wow/playable-specialization/index?#{build_query()}")
  end
  def get_spec(id)
    req("/data/wow/playable-specialization/#{id}?#{build_query()}")
  end
  def get_powers()
    req("/data/wow/power-type/index?#{build_query()}")
  end
  def get_power(id)
    req("/data/wow/power-type/#{id}?#{build_query()}")
  end
  def get_talents()
    req("/data/wow/talent/index?#{build_query()}")
  end
  def get_talent(id)
    req("/data/wow/talent/#{id}?#{build_query()}")
  end
  def get_talent_trees()
    req("/data/wow/talent-tree/index?#{build_query()}")
  end
  def get_talent_tree(id)
    req("/data/wow/talent-tree/#{id}?#{build_query()}")
  end

  def get_spell(id) do
    req("/data/wow/spell/#{id}?#{build_query()}")
  end
  def get_spell_media(id) do
    req("/data/wow/media/spell/#{id}?#{build_query()}")
  end

  def get_creature(id) do
    req("/data/wow/creature/#{id}?#{build_query()}")
  end

  def get_item(id) do
    req("/data/wow/item/#{id}?#{build_query()}")
  end
  def get_item_media(id) do
    req("/data/wow/media/item/#{id}?#{build_query()}")
  end
  def get_item_set(id) do
    req("/data/wow/item-set/#{id}?#{build_query()}")
  end

  def get_keystone(id) do
    req("/data/wow/mythic-keystone/dungeon/#{id}?#{build_query()}")
  end
  def get_keystone_periods()
    req("/data/wow/mythic-keystone/period/index?#{build_query()}")
  end
  def get_keystone_period(id)
    req("/data/wow/mythic-keystone/period/#{id}?#{build_query()}")
  end
  def get_keystone_seasons()
    req("/data/wow/mythic-keystone/season/index?#{build_query()}")
  end
  def get_keystone_season(id)
    req("/data/wow/mythic-keystone/season/#{id}?#{build_query()}")
  end
end
