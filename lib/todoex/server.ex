defmodule Todoex.Server do
  alias Todoex.{Database, List, ProcessRegistry}

  use GenServer, restart: :temporary

  @idle_timout :timer.seconds(20)

  def start_link(name) do
    IO.puts("Starting Todoex.Server (name: #{name})")
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
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

  def init(name) do
    send(self(), :load)
    {:ok, {name, nil}}
  end

  def handle_info(:load, {name, nil}) do
    list = Database.get(name) || List.new()
    IO.puts("Loading list to server: #{inspect(list)}")
    {:noreply, {name, list}, @idle_timout}
  end

  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping Todoex.Server (name: #{name})")
    {:stop, :normal, {name, todo_list}}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = List.add_entry(todo_list, new_entry)
    Database.store(name, new_list)
    {:noreply, {name, new_list}, @idle_timout}
  end

  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_list = List.delete_entry(todo_list, entry_id)
    Database.store(name, new_list)
    {:noreply, {name, new_list}, @idle_timout}
  end

  def handle_cast({:update_entry, entry}, {name, todo_list}) do
    new_list = List.update_entry(todo_list, entry)
    Database.store(name, new_list)
    {:noreply, {name, new_list}, @idle_timout}
  end

  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, List.entries(todo_list, date), {name, todo_list}, @idle_timout}
  end

  defp via_tuple(name) do
    ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
