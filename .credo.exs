%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "web/", "apps/"],
        excluded: []
      },
      plugins: [],
      requires: [],
      strict: false,
      parse_timeout: 5000,
      color: false,
      checks: [
        {Credo.Check.Design.AliasUsage, priority: :low},
        {Credo.Check.Readability.ModuleDoc, priority: :low}
        # ... other checks omitted for readability ...
      ]
    }
  ]
}
