# error messaging is reasonably helpful

    Code
      text_parse(text)
    Condition
      Error in `text_parse()`:
      ! Can't parse when there are parse errors.
      i Colon expected
      {
        "a" 1
      }

---

    Code
      text_parse(text)
    Condition
      Error in `text_parse()`:
      ! Can't parse when there are parse errors.
      i Value expected
      {
        "a": ]
      }

---

    Code
      text_parse(text)
    Condition
      Error in `text_parse()`:
      ! Can't parse when there are parse errors.
      i Invalid symbol
        "a": [
          1,
          2,
          b"
        ]
      }
      i Unexpected end of string
        "a": [
          1,
          2,
          b"
        ]
      }

---

    Code
      text_parse(text)
    Condition
      Error in `text_parse()`:
      ! Can't parse when there are parse errors.
      i Invalid symbol
      {
        "a": [
          b",
          2,
          3
        ]
      
      i Unexpected end of string
      {
        "a": [
          b",
          2,
          3
        ]
      }

# `allow_comments` works

    Code
      text_parse(text, parse_options = options)
    Condition
      Error in `text_parse()`:
      ! Can't parse when there are parse errors.
      i Invalid comment token
      
        {
          // A comment!
          "a": 1
        }
        

# `allow_trailing_comma` works

    Code
      text_parse(text, parse_options = options)
    Condition
      Error in `text_parse()`:
      ! Can't parse when there are parse errors.
      i Property name expected
      
        {
          "a": 1,
        }
        
      i Value expected
      
        {
          "a": 1,
        }
        

# `allow_empty_content` works

    Code
      text_parse("", parse_options = options)
    Condition
      Error in `text_parse()`:
      ! Can't parse when there are parse errors.
      i Value expected

