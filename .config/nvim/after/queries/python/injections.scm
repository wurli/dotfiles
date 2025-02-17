;; extends

;; Pydocs

; function/method docstring
; inject ReStructuredText
(function_definition
  body: (block .
    (expression_statement
      (string
        (string_content) @injection.content (#set! injection.language "rst")
      )
    )
  )
)
