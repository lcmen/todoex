defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{}, &add_entry(&2, &1))
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    %TodoList{todo_list | entries: Map.put(todo_list.entries, entry.id, entry), next_id: todo_list.next_id + 1}
  end

  def update_entry(todo_list, %{} = entry) do
    update_entry(todo_list, entry.id, fn _ -> entry end)
  end

  def delete_entry(todo_list, id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, id)}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  defp update_entry(todo_list, entry_id, updater) do
    case Map.fetch(todo_list.entries, entry_id) do
      {:ok, entry} ->
        entry = updater.(entry)
        entries = Map.put(todo_list.entries, entry.id, entry)
        %TodoList{todo_list | entries: entries}
      :error -> todo_list
    end
  end
end

defmodule TodoServer do
  def start do
    spawn(fn ->
      Process.register(self(), :todo_server)
      loop(TodoList.new())
    end)
  end

  def add_entry(new_entry) do
    send(:todo_server, {:add_entry, new_entry})
  end

  def delete_entry(entry_id) do
    send(:todo_server, {:delete_entry, entry_id})
  end

  def update_entry(entry) do
    send(:todo_server, {:update_entry, entry})
  end

  def entries(date) do
    send(:todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process(todo_list, message)
      end

    loop(new_todo_list)
  end

  defp process(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process(todo_list, {:delete_entry, entry_id}) do
    TodoList.delete_entry(todo_list, entry_id)
  end

  defp process(todo_list, {:update_entry, entry}) do
    TodoList.update_entry(todo_list, entry)
  end

  defp process(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end
end
