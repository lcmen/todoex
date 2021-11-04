defmodule Todoex.MixProject do
  use Mix.Project

  def project do
    [
      app: :todoex,
      version: "0.1.0",
      elixir: "~> 1.12",
      deps: deps(),
      preferred_cli_env: [release: :prod],
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {Todoex.Application, []}
    ]
  end

  defp deps do
    [
      {:distillery, "~> 2.1"},
      {:poolboy, "~> 1.5"},
      {:plug, "~> 1.12"},
      {:plug_cowboy, "~> 2.5"}
    ]
  end
end
