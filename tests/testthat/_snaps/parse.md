# `allow_comments` works

    Code
      text_parse(text, parse_options = options)
    Condition
      Error in `text_parse()`:
      ! Can't parse when there are parse errors.

# `allow_trailing_comma` works

    Code
      text_parse(text, parse_options = options)
    Condition
      Error in `text_parse()`:
      ! Can't parse when there are parse errors.

# `allow_empty_content` works

    Code
      text_parse("", parse_options = options)
    Condition
      Error in `text_parse()`:
      ! Can't parse when there are parse errors.

