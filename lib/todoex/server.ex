defmodule Todoex.Server do
  alias Todoex.List

  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  def update_entry(pid, entry) do
    GenServer.cast(pid, {:update_entry, entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
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
