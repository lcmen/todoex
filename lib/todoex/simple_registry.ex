# This is not used by Todoex application.
# It's built only for educational purposes as ets table exercise.
defmodule Todoex.SimpleRegistry do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(name) do
    Process.link(Process.whereis(__MODULE__))

    if :ets.insert_new(__MODULE__, {name, self()}) do
      :ok
    else
      :error
    end
  end

  def whereis(name) do
    case :ets.lookup(__MODULE__, name) do
      [{^name, pid}] -> pid
      [] -> nil
    end
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    :ets.new(__MODULE__, [:named_table, :public])
    {:ok, nil}
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    IO.puts("Deleting #{inspect(pid)}")
    :ets.match_delete(__MODULE__, {:_, pid})
    {:noreply, state}
  end
end
