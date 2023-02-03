defmodule Wowlr.Bnet.LiveAdapter do
  @behaviour Wowlr.Bnet
  import Wowlr.Bnet.Utils,
    only: [base_url: 0, base_url: 1, get_auth_header: 0, unwrap_response: 1, build_query: 1]

  @impl true
  def get_spell(id),
    do: request("/data/wow/spell/#{id}?#{build_query(%{namespace: "static"})}")

  @impl true
  def get_spell_media(id),
    do: request("/data/wow/media/spell/#{id}?#{build_query(%{namespace: "static"})}")

  @impl true
  def get_character({region, realm, name}) do
    query = build_query(%{namespace: "profile", region: region})
    url = base_url(region) <> "/profile/wow/character/#{realm}/#{name}?#{query}"
    request(url)
  end

  defp request(url) do
    with {:ok, _} <- Wowlr.Bnet.Auth.ensure_auth() do
      Finch.build(:get, base_url() <> url, get_auth_header())
      |> Finch.request(MyFinch)
      |> unwrap_response()
    end
  end
end
