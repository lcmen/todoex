defmodule Todoex.Metrics do
  alias Todoex.Metrics.Report
  use Task

  def start_link(_) do
    Task.start_link(&loop/0)
  end

  defp loop do
    Process.sleep(:timer.seconds(10))
    spawn(&Report.report/0)
    loop()
  end
end
