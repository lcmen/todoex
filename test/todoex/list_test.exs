defmodule Todoex.ListTest do
  use ExUnit.Case, async: true

  alias Todoex.List

  test "initialization" do
    assert List.size(List.new()) == 0

    todo_list =
      List.new([
        %{date: ~D[2018-12-19], title: "Dentist"},
        %{date: ~D[2018-12-20], title: "Shopping"},
        %{date: ~D[2018-12-19], title: "Movies"}
      ])

    assert List.size(todo_list) == 3
    assert List.entries(todo_list, ~D[2018-12-19]) |> length() == 2
    assert List.entries(todo_list, ~D[2018-12-20]) |> length() == 1
    assert List.entries(todo_list, ~D[2018-12-21]) |> length() == 0

    titles = List.entries(todo_list, ~D[2018-12-19]) |> Enum.map(& &1.title)
    assert ["Dentist", "Movies"] = titles
  end

  test "adding new entry" do
    todo_list =
      List.new()
      |> List.add_entry(%{date: ~D[2018-12-19], title: "Dentist"})
      |> List.add_entry(%{date: ~D[2018-12-20], title: "Shopping"})
      |> List.add_entry(%{date: ~D[2018-12-19], title: "Movies"})

    assert List.size(todo_list) == 3
    assert List.entries(todo_list, ~D[2018-12-19]) |> length() == 2
    assert List.entries(todo_list, ~D[2018-12-20]) |> length() == 1
    assert List.entries(todo_list, ~D[2018-12-21]) |> length() == 0

    titles = List.entries(todo_list, ~D[2018-12-19]) |> Enum.map(& &1.title)
    assert ["Dentist", "Movies"] = titles
  end

  test "updating entry" do
    todo_list =
      List.new()
      |> List.add_entry(%{date: ~D[2018-12-19], title: "Dentist"})
      |> List.add_entry(%{date: ~D[2018-12-20], title: "Shopping"})
      |> List.add_entry(%{date: ~D[2018-12-19], title: "Movies"})
      |> List.update_entry(%{id: 2, date: ~D[2018-12-20], title: "Updated shopping"})

    assert List.size(todo_list) == 3
    assert [%{title: "Updated shopping"}] = List.entries(todo_list, ~D[2018-12-20])
  end

  test "deleting entry" do
    todo_list =
      List.new()
      |> List.add_entry(%{date: ~D[2018-12-19], title: "Dentist"})
      |> List.add_entry(%{date: ~D[2018-12-20], title: "Shopping"})
      |> List.add_entry(%{date: ~D[2018-12-19], title: "Movies"})
      |> List.delete_entry(2)

    assert List.size(todo_list) == 2
    assert List.entries(todo_list, ~D[2018-12-20]) == []
  end
end
