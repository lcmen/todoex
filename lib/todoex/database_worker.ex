defmodule Todoex.DatabaseWorker do
  use GenServer

  def start_link(folder) do
    IO.puts("Starting Todoex.DatabaseWorker on #{folder}")
    GenServer.start_link(__MODULE__, folder)
  end

  def store(pid, key, data) do
    GenServer.call(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def init(folder) do
    File.mkdir_p!(folder)
    {:ok, folder}
  end

  def handle_call({:get, key}, _, folder) do
    data =
      case File.read(file_name(key, folder)) do
        {:ok, content} -> :erlang.binary_to_term(content)
        {:error, :enoent} -> nil
      end

    {:reply, data, folder}
  end

  def handle_call({:store, key, data}, _, folder) do
    key
    |> file_name(folder)
    |> File.write!(:erlang.term_to_binary(data))

    {:reply, :ok, folder}
  end

  defp file_name(key, folder) do
    Path.join(folder, to_string(key))
  end
end
