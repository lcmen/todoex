defmodule Todoex.Server do
  alias Todoex.{Database, List, ProcessRegistry}

  use Agent, restart: :temporary

  def start_link(name) do
    IO.puts("Starting Todoex.Server (name: #{name})")

    Agent.start_link(
      fn ->
        list = Database.get(name) || List.new()
        IO.puts("Loading list to server: #{inspect(list)}")
        {name, list}
      end,
      name: via_tuple(name)
    )
  end

  def add_entry(pid, entry) do
    Agent.cast(pid, fn {name, list} ->
      new_list = List.add_entry(list, entry)
      Database.store(name, new_list)
      {name, new_list}
    end)
  end

  def delete_entry(pid, entry_id) do
    Agent.cast(pid, fn {name, list} ->
      new_list = List.delete_entry(list, entry_id)
      Database.store(name, new_list)
      {name, new_list}
    end)
  end

  def update_entry(pid, entry) do
    Agent.cast(pid, fn {name, list} ->
      new_list = List.update_entry(list, entry)
      Database.store(name, new_list)
      {name, new_list}
    end)
  end

  def entries(pid, date) do
    Agent.get(pid, fn {_name, list} -> List.entries(list, date) end)
  end

  defp via_tuple(name) do
    ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
