defmodule Todoex.MixProject do
  use Mix.Project

  def project do
    [
      app: :todoex,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Todoex.Application, []}
    ]
  end

  defp deps do
    [
      {:poolboy, "~> 1.5"},
      {:plug, "~> 1.12"},
      {:plug_cowboy, "~> 2.5"}
    ]
  end
end
