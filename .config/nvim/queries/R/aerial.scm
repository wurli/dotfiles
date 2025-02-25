;; extends

((comment) @name
    (#lua-match? @name "(%S)%1%1%1$")
    (#gsub! @name "%s+%S+$" "")
    (#gsub! @name "#%s+" "")
    (#set! "kind" "Interface")) @symbol

(binary_operator
    lhs: ((identifier) @name)
    rhs: (function_definition)
    (#set! "kind" "Function")) @symbol
