(pair
  key: (string
    (string_content) @name)
  value: (object) @symbol
  (#not-has-ancestor? @symbol array)
  (#set! "kind" "Class")) @start

(pair
  key: (string
    (string_content) @name)
  value: (array) @symbol
  (#not-has-ancestor? @symbol array)
  (#set! "kind" "Array")) @start

(pair
  key: (string
    (string_content) @name)
  value: (null) @symbol
  (#not-has-ancestor? @symbol array)
  (#set! "kind" "Null")) @start

(pair
  key: (string
    (string_content) @name)
  value: (string) @symbol
  (#not-has-ancestor? @symbol array)
  (#set! "kind" "String")) @start

(pair
  key: (string
    (string_content) @name)
  value: (number) @symbol
  (#not-has-ancestor? @symbol array)
  (#set! "kind" "Number")) @start

(pair
  key: (string
    (string_content) @name)
  value: [(true) (false)] @symbol
  (#not-has-ancestor? @symbol array)
  (#set! "kind" "Boolean")) @start
