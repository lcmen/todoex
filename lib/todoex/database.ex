defmodule Todoex.Database do
  alias Todoex.DatabaseWorker

  @folder "./persist"
  @pool 3

  def child_spec(_) do
    File.mkdir_p!(@folder)

    :poolboy.child_spec(
      __MODULE__,
      [name: {:local, __MODULE__}, worker_module: DatabaseWorker, size: @pool],
      [@folder]
    )
  end

  def store(key, data) do
    :poolboy.transaction(__MODULE__, fn pid -> DatabaseWorker.store(pid, key, data) end)
  end

  def get(key) do
    :poolboy.transaction(__MODULE__, fn pid -> DatabaseWorker.get(pid, key) end)
  end
end
