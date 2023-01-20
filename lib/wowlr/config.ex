defmodule Wowlr.Config do
  @moduledoc """
  A basic persistent storage for settings and other misc data.
  It is implemented using :ets and writes to file with every change
  
  Target file: AppData/local/WowLr/settings
  """

  @table :settings
  use GenServer

  ## specific settings

  @doc """
  get the directory we store our data in
  """
  def data_dir() do
    :filename.basedir(:user_data, "WowLr")
  end

  @doc "get the game path"
  def game_dir(), do: get(:gamedir, "C:\\ProgramFiles(x86)\\WorldofWarcraft\\_retail_")

  @doc "get active locale"
  def locale(), do: get(:locale, "en_US")

  @doc "client_id for battlenet api"
  def bnet_client_id(), do: get(:bnet_client_id, nil)

  @doc "client secret for battlenet api"
  def bnet_client_secret(), do: get(:bnet_client_secret, nil)

  ## Generic getter/setter stuff

  @doc "update a setting and persist it"
  def set(key, value) do
    GenServer.cast(__MODULE__, {:write, key, value})
  end

  @doc "get a setting value"
  def get(key) do
    case :ets.lookup(:settings, key) do
      [{key, value}] -> {:ok, value}
      _ -> {:error, :notfound}
    end
  end

  def get!(key) do
    case get(key) do
      {:ok, value} -> value
      {:error, e} -> raise(e)
    end
  end

  def get(key, default) do
    case get(key) do
      {:ok, val} -> val
      _ -> default
    end
  end

  #######################
  ### GenServer Stuff ###
  #######################

  @impl GenServer
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    file_path = Path.join(data_dir(), "settings")
    File.mkdir_p!(data_dir())

    case File.exists?(file_path) do
      true -> :ets.file2tab(String.to_charlist(file_path))
      false -> :ets.new(@table, [:set, :protected, :named_table])
    end

    {:ok, file_path}
  end

  def handle_cast({:write, key, value}, state) do
    :ets.insert(@table, {key, value})
    :ets.tab2file(@table, state)
    {:noreply, state}
  end
end
