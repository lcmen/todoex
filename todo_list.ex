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
    case Map.fetch(todo_list.entries, entry.id) do
      {:ok, _} ->
        entries = Map.put(todo_list.entries, entry.id, entry)
        %TodoList{todo_list | entries: entries}
      :error -> todo_list
    end
  end

  def delete_entry(todo_list, id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, id)}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end
end

defmodule TodoServer do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil, [name: __MODULE__])
  end

  def add_entry(entry) do
    GenServer.cast(__MODULE__, {:add_entry, entry})
  end

  def delete_entry(entry_id) do
    GenServer.cast(__MODULE__, {:delete_entry, entry_id})
  end

  def update_entry(entry) do
    GenServer.cast(__MODULE__, {:update_entry, entry})
  end

  def entries(date) do
    GenServer.call(__MODULE__, {:entries, date})
  end

  def init(_) do
    {:ok, TodoList.new()}
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    {:noreply, TodoList.add_entry(todo_list, new_entry)}
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    {:noreply, TodoList.delete_entry(todo_list, entry_id)}
  end

  def handle_cast({:update_entry, entry}, todo_list) do
    {:noreply, TodoList.update_entry(todo_list, entry)}
  end

  def handle_call({:entries, date}, _, todo_list) do
    {:reply, TodoList.entries(todo_list, date), todo_list}
  end
end
