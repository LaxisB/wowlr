defmodule Wowlr.Bnet.Profile do
  import Wowlr.Bnet, only: [base_url: 0, base_url: 1, get_auth_header: 0, unwrap_response: 1]

  def build_query(opts \\ %{}) do
    Wowlr.Bnet.build_query(Map.put(opts, :namespace, "profile"))
  end

  defp req(url) do
    Finch.build(:get, url, get_auth_header())
    |> Finch.request(MyFinch)
    |> unwrap_response()
  end

  def get_character({region, realm, name}) do
    query = build_query(%{region: region})
    url = base_url(region) <> "/profile/wow/character/#{realm}/#{name}?#{query}"
    req(url)
  end

  def get_character_media({region, realm, name}) do
    query = build_query(%{region: region})
    url = base_url(region) <> "/profile/wow/character/#{realm}/#{name}/character-media?#{query}"
    req(url)
  end

  def get_character_equipment({region, realm, name}) do
    query = build_query(%{region: region})
    url = base_url(region) <> "/profile/wow/character/#{realm}/#{name}/equipment?#{query}"
    req(url)
  end

  def get_character_status({region, realm, name}) do
    query = build_query(%{region: region})
    url = base_url(region) <> "/profile/wow/character/#{realm}/#{name}/status?#{query}"
    req(url)
  end

  def get_character_dungeons({region, realm, name}) do
    query = build_query(%{region: region})
    url = base_url(region) <> "/profile/wow/character/#{realm}/#{name}/dungeons?#{query}"
    req(url)
  end

  def get_character_raids({region, realm, name}) do
    query = build_query(%{region: region})
    url = base_url(region) <> "/profile/wow/character/#{realm}/#{name}/raids?#{query}"
    req(url)
  end

  def get_character_keystone_profile({region, realm, name}) do
    query = build_query(%{region: region})

    url =
      base_url(region) <>
        "/profile/wow/character/#{realm}/#{name}/mythic-keystone-profile?#{query}"

    req(url)
  end

  def get_character_status({region, realm, name}, season) do
    query = build_query(%{region: region})
    url = base_url(region) <> "/profile/wow/character/#{realm}/#{name}/season/#{season}?#{query}"
    req(url)
  end

  def get_character_spec({region, realm, name}, season) do
    query = build_query(%{region: region})
    url = base_url(region) <> "/profile/wow/character/#{realm}/#{name}/specializations?#{query}"
    req(url)
  end
end
