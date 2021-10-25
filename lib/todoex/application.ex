defmodule Todoex.Application do
  use Application

  def start(_, _) do
    Todoex.System.start_link()
  end
end
