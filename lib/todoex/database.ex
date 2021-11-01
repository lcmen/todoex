defmodule Todoex.Database do
  alias Todoex.DatabaseWorker

  @folder "./persist"
  @pool 3

  def child_spec(_) do
    path = "#{@folder}/#{Node.self()}"

    :poolboy.child_spec(
      __MODULE__,
      [name: {:local, __MODULE__}, worker_module: DatabaseWorker, size: @pool],
      [path]
    )
  end

  def store(key, data) do
    {_results, bad_nodes} = :rpc.multicall(__MODULE__, :store_local, [key, data], :timer.seconds(5))

    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
    :ok
  end

  def store_local(key, data) do
    :poolboy.transaction(__MODULE__, fn pid -> DatabaseWorker.store(pid, key, data) end)
  end

  def get(key) do
    :poolboy.transaction(__MODULE__, fn pid -> DatabaseWorker.get(pid, key) end)
  end
end
