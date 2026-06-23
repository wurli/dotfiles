; objects
(pair
  key: (string
    (string_content) @name)
  value: (object) @symbol
  (#not-has-ancestor? @symbol array)
  (#set! "kind" "Class")) @start

; arrays
(pair
  key: (string
    (string_content) @name)
  value: (array) @symbol
  (#not-has-ancestor? @symbol array)
  (#set! "kind" "Array")) @start

; root-level nulls
(document
  (object
    (pair
      key: (string
        (string_content) @name)
      value: (null) @symbol
      (#set! "kind" "Null")) @start))

; root-level strings
(document
  (object
    (pair
      key: (string
        (string_content) @name)
      value: (string) @symbol
      (#set! "kind" "String")) @start))

; root-level numbers
(document
  (object
    (pair
      key: (string
        (string_content) @name)
      value: (number) @symbol
      (#set! "kind" "Number")) @start))

; root-level booleans
(document
  (object
    (pair
      key: (string
        (string_content) @name)
      value: [(true) (false)] @symbol
      (#set! "kind" "Boolean")) @start))
