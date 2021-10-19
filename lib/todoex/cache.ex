defmodule Todoex.Cache do
  alias Todoex.Server

  def child_spec(_) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, []}, type: :supervisor}
  end

  def start_link do
    IO.puts("Starting Todoex.Cache")

    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def server_process(name) do
    case start_child(name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(name) do
    DynamicSupervisor.start_child(__MODULE__, {Server, name})
  end
end
