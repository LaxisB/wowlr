defmodule Wowlr.Bnet.Utils do
  alias Wowlr.Config

  def base_url(), do: base_url(Config.region())
  def base_url(region), do: "https://#{region}.api.blizzard.com"

  def get_auth_header() do
    token = Wowlr.Config.auth_token()
    [{"authorization", "Bearer #{token}"}]
  end

  def build_query(%{} = opts) do
    given_namespace = Map.get(opts, :namespace, "static")
    updated = Map.drop(opts, [:namespace])

    Map.merge(
      %{
        locale: Config.locale(),
        region: Config.region(),
        namespace: given_namespace <> "-" <> Config.region()
      },
      updated
    )
    |> URI.encode_query()
  end

  def unwrap_response({:error, res}), do: {:error, res}

  def unwrap_response({:ok, %Finch.Response{status: status, body: ""}})
      when status >= 200 and status < 300 do
    {:ok, nil}
  end

  def unwrap_response({:ok, %Finch.Response{status: status, body: ""}}) do
    {:error, :no_body, status}
  end

  def unwrap_response({:ok, %Finch.Response{status: status, body: body}}) do
    {:ok, payload} = Jason.decode(body)

    case status do
      x when x in 200..299 -> {:ok, payload}
      x when x in 400..499 -> {:error, :client_error, body}
      x when x in 500..599 -> {:error, :server_error, body}
    end
  end
end
