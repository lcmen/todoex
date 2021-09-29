defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  def call(pid, request) do
    send(pid, {:call, request, self()})

    receive do
      {:response, response} ->
        response
    end
  end

  def cast(pid, request) do
    send(pid, {:cast, request})
  end

  defp loop(callback_module, state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(request, state)
        send(caller, {:response, response})
        loop(callback_module, new_state)
      {:cast, request} ->
        new_state = callback_module.handle_cast(request, state)
        loop(callback_module, new_state)
    end
  end
end

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
    ServerProcess.start(TodoServer)
  end

  def init() do
    Process.register(self(), :todo_server)
    TodoList.new()
  end

  def add_entry(new_entry) do
    ServerProcess.cast(:todo_server, {:add_entry, new_entry})
  end

  def delete_entry(entry_id) do
    ServerProcess.cast(:todo_server, {:delete_entry, entry_id})
  end

  def update_entry(entry) do
    ServerProcess.cast(:todo_server, {:update_entry, entry})
  end

  def entries(date) do
    ServerProcess.call(:todo_server, {:entries, date})
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    TodoList.add_entry(todo_list, new_entry)
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    TodoList.delete_entry(todo_list, entry_id)
  end

  def handle_cast({:update_entry, entry}, todo_list) do
    TodoList.update_entry(todo_list, entry)
  end

  def handle_call({:entries, date}, todo_list) do
    {TodoList.entries(todo_list, date), todo_list}
  end
end
