defmodule Todoex.DatabaseWorker do
  alias Todoex.ProcessRegistry

  use GenServer

  def start_link({folder, id}) do
    IO.puts("Starting Todoex.DatabaseWorker #{id}")
    GenServer.start_link(__MODULE__, folder, name: via_tuple(id))
  end

  def store(id, key, data) do
    GenServer.cast(via_tuple(id), {:store, key, data})
  end

  def get(id, key) do
    GenServer.call(via_tuple(id), {:get, key})
  end

  def init(folder) do
    File.mkdir_p!(folder)
    {:ok, folder}
  end

  def handle_cast({:store, key, data}, folder) do
    key
    |> file_name(folder)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, folder}
  end

  def handle_call({:get, key}, _, folder) do
    data =
      case File.read(file_name(key, folder)) do
        {:ok, content} -> :erlang.binary_to_term(content)
        {:error, :enoent} -> nil
      end

    {:reply, data, folder}
  end

  defp file_name(key, folder) do
    Path.join(folder, to_string(key))
  end

  defp via_tuple(id) do
    ProcessRegistry.via_tuple({__MODULE__, id})
  end
end
