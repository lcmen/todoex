defmodule Todoex.ServerTest do
  use ExUnit.Case

  alias Todoex.Server

  setup do
    {:ok, server} = Server.start()
    %{server: server}
  end

  test "adding entities", %{server: server} do
    Server.add_entry(server, %{date: ~D[2021-10-02], title: "Dentist"})
    assert [%{date: ~D[2021-10-02], title: "Dentist"}] = Server.entries(server, ~D[2021-10-02])
  end
end
