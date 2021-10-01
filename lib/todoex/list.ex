defmodule Todoex.List do
  alias Todoex.List

  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %List{}, &add_entry(&2, &1))
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    %List{
      todo_list
      | entries: Map.put(todo_list.entries, entry.id, entry),
        next_id: todo_list.next_id + 1
    }
  end

  def update_entry(todo_list, %{} = entry) do
    case Map.fetch(todo_list.entries, entry.id) do
      {:ok, _} ->
        entries = Map.put(todo_list.entries, entry.id, entry)
        %List{todo_list | entries: entries}

      :error ->
        todo_list
    end
  end

  def delete_entry(todo_list, id) do
    %List{todo_list | entries: Map.delete(todo_list.entries, id)}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end
end
