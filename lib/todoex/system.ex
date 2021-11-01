defmodule Todoex.System do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    Supervisor.init(
      [
        Todoex.Cache,
        Todoex.Database,
        Todoex.Metrics,
        Todoex.Web
      ],
      strategy: :one_for_one
    )
  end
end
