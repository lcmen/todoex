defmodule Todoex.Database do
  alias Todoex.DatabaseWorker

  @folder "./persist"
  @pool 3

  def child_spec(_) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, []}, type: :supervisor}
  end

  def start_link do
    File.mkdir_p!(@folder)

    Supervisor.start_link(
      Enum.map(1..@pool, fn i -> Supervisor.child_spec({DatabaseWorker, {@folder, i}}, id: i) end),
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  def store(key, data) do
    key
    |> choose_worker
    |> DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker
    |> DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool + 1)
  end
end
