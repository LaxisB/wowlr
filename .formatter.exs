[
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"],
  locals_without_parens: [plug: 1, plug: 2, defparsec: 2, defcombinator: 2, defcombinatorp: 2]
]
