defmodule Todoex.Metrics.Report do
  use Task

  def report do
    IO.inspect(collect_metrics())
  end

  defp collect_metrics do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end
end
