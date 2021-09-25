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

defmodule TodoList.CsvImporter do
  def import(file_path) do
    file_path
    |> read_file()
    |> parse()
    |> TodoList.new()
  end

  defp read_file(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  defp parse(lines) do
    lines
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn [date, title] -> %{date: date, title: title} end)
  end
end

IO.inspect TodoList.CsvImporter.import("./todos.csv")
