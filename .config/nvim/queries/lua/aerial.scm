;; extends

((comment_content) @name
    (#lua-match? @name "(%S)%1%1%1$")
    (#gsub! @name "%s+%S+$" "")
    (#set! "kind" "Interface")) @symbol

