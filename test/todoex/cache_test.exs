defmodule Todoex.CacheTest do
  use ExUnit.Case

  alias Todoex.Cache

  test "caching server processes" do
    {:ok, _} = Cache.start()
    pid = Cache.server_process("bob")

    assert pid != Cache.server_process("alice")
    assert pid == Cache.server_process("bob")
  end
end
