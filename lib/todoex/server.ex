defmodule Todoex.Server do
  alias Todoex.List

  use GenServer

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
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
    {:ok, List.new()}
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    {:noreply, List.add_entry(todo_list, new_entry)}
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    {:noreply, List.delete_entry(todo_list, entry_id)}
  end

  def handle_cast({:update_entry, entry}, todo_list) do
    {:noreply, List.update_entry(todo_list, entry)}
  end

  def handle_call({:entries, date}, _, todo_list) do
    {:reply, List.entries(todo_list, date), todo_list}
  end
end
