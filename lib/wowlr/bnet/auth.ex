defmodule Wowlr.Bnet.Auth do
  @base_url "https://oauth.battle.net/token"
  alias Wowlr.Config

  def authorize() do
    auth =
      [Config.bnet_client_id(), Config.bnet_client_secret()]
      |> Enum.join(":")
      |> Base.encode64()

    query =
      URI.encode_query(%{
        client_id: Config.bnet_client_id(),
        client_secret: Config.bnet_client_secret(),
        grant_type: "client_credentials"
      })

    req =
      Finch.build(
        :post,
        @base_url <> "?" <> query,
        [{"authorization", auth}]
      )

    with {:res, {:ok, %Finch.Response{status: 200, body: body}}} <-
           {:res, Finch.request(req, MyFinch)},
         {:body, {:ok, res}} <- {:body, Jason.decode(body)},
         {:keys, %{"access_token" => token, "expires_in" => expiry}} <- {:keys, res} do
      Wowlr.Config.set_auth_token(token, expiry)
      :ok
    else
      {:res, {:error, reason}} -> {:error, :request_failed, reason}
      {:body, {:error, reason}} -> {:error, :decode_failedm, reason}
      {:keys, body} -> {:error, :bad_res, body}
    end
  end

  def ensure_auth() do
    case Wowlr.Config.auth_token() do
      nil -> authorize()
      _ -> {:ok, :authed}
    end
  end
end
