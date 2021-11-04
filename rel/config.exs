use Distillery.Releases.Config,
    default_release: :default,
    default_environment: :prod

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"9)Iwm*Xg6P&4EA2P2h!AryVxoyVMO&5f1lZ|v7;:Bxq|l6r&I>(v[7L`g~ekw)j&"
end

release :todoex do
  set version: current_version(:todoex)
end
