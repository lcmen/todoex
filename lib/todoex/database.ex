defmodule Todoex.Database do
  alias Todoex.DatabaseWorker

  use GenServer

  @folder "./persist"
  @pool 3

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def init(_) do
    workers =
      Enum.reduce(0..(@pool - 1), %{}, fn i, acc ->
        {:ok, pid} = DatabaseWorker.start(@folder)
        Map.put(acc, i, pid)
      end)

    {:ok, workers}
  end

  def handle_cast({:store, key, data}, workers) do
    key
    |> choose_worker(workers)
    |> DatabaseWorker.store(key, data)

    {:noreply, workers}
  end

  def handle_call({:get, key}, caller, workers) do
    spawn(fn ->
      data =
        key
        |> choose_worker(workers)
        |> DatabaseWorker.get(key)

      GenServer.reply(caller, data)
    end)

    {:noreply, workers}
  end

  defp choose_worker(key, workers) do
    index = :erlang.phash2(key, 3)
    Map.get(workers, index)
  end
end
