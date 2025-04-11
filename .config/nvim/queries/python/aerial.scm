;; extends

((comment) @name
    (#lua-match? @name "(%S)%1%1%1$")
    (#lua-match? @name "[-=]$")
    (#gsub! @name "%s+%S+$" "")
    (#gsub! @name "#[%s-=]+" "")
    (#set! "kind" "Interface")) @symbol

