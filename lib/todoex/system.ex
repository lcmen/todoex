defmodule Todoex.System do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    Supervisor.init(
      [
        Todoex.ProcessRegistry,
        Todoex.Cache,
        Todoex.Database,
        Todoex.Metrics
      ],
      strategy: :one_for_one
    )
  end
end
