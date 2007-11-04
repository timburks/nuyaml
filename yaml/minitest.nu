(load "YAML")
(set mmm (dict "meh" "huh" "t-rex" "green" "utah" "raptor" "patrick" "t"))
(set xxx (NSDictionary fromYAML: (mmm yamlDescription)))
(puts (xxx class))