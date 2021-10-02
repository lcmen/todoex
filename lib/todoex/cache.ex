defmodule Todoex.Cache do
  alias Todoex.Server

  use GenServer

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(name) do
    GenServer.call(__MODULE__, {:server_process, name})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:server_process, name}, _, servers) do
    case Map.fetch(servers, name) do
      {:ok, server} ->
        {:reply, server, servers}

      :error ->
        {:ok, server} = Server.start()
        {:reply, server, Map.put(servers, name, server)}
    end
  end
end
