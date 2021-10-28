use Mix.Config

config :todoex, http_port: 5454

import_config "#{Mix.env()}.exs"
