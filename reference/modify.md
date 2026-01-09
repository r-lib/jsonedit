# Modify a JSON file or string

Set or delete fields in a JSON file or string while retaining comments
and whitespace.

## Usage

``` r
text_modify(
  text,
  path,
  value,
  ...,
  parse_options = NULL,
  modification_options = NULL
)

file_modify(
  file,
  path,
  value,
  ...,
  parse_options = NULL,
  modification_options = NULL
)

modification_options(formatting_options = NULL, is_array_insertion = FALSE)
```

## Arguments

- text:

  A single string containing JSON to modify.

- path:

  Either:

  - A character vector representing a path to a JSON element by name,
    i.e. `c("[r]", "editor.formatOnSave")`.

  - A list of strings or numbers representing a path to a JSON element
    by name and position, i.e. `list("[r]", "editor.rulers", 2)`.

  Numeric positions are specified as positive integers and are only
  applicable for arrays. `-1` is specially recognized as a request to
  *insert* at the end of an array.

- value:

  New value. Wrap in
  [`V8::JS()`](https://jeroen.r-universe.dev/V8/reference/JS.html) to
  specify literal JavaScript value. Use `NULL` to delete the field.

- ...:

  These dots are for future extensions and must be empty.

- parse_options:

  The result of
  [`parse_options()`](https://jsonedit.r-lib.org/reference/parse.md). If
  `NULL`, a default set of options are used.

- modification_options:

  The result of `modification_options()`. If `NULL`, a default set of
  options are used.

- file:

  Path to file on disk. File must exist.

- formatting_options:

  The result of a call to
  [`formatting_options()`](https://jsonedit.r-lib.org/reference/format.md).
  If `NULL`, a default set of options are used.

- is_array_insertion:

  Whether or not to treat the change as an *insertion* at the specified
  `path` rather than a *modification* at that `path`. Only applicable
  for arrays.

## Examples

``` r
text <- "{}"

text <- text_modify(text, c('[r]', 'editor.formatOnSave'), TRUE)
cat(text)
#> {
#>     "[r]": {
#>         "editor.formatOnSave": true
#>     }
#> }

text <- text_modify(text, c('[r]', 'editor.formatOnSave'), NULL)
cat(text)
#> {
#>     "[r]": {
#>     }
#> }

# Insert an array
text <- text_modify(text, "foo", 1:3)
cat(text)
#> {
#>     "[r]": {
#>     },
#>     "foo": [
#>         1,
#>         2,
#>         3
#>     ]
#> }

# Update the array at location 2
cat(text_modify(text, list("foo", 2), 0))
#> {
#>     "[r]": {
#>     },
#>     "foo": [
#>         1,
#>         0,
#>         3
#>     ]
#> }

# Insert at location 2
cat(text_modify(
  text,
  list("foo", 2),
  0,
  modification_options = modification_options(is_array_insertion = TRUE)
))
#> {
#>     "[r]": {
#>     },
#>     "foo": [
#>         1,
#>         0,
#>         2,
#>         3
#>     ]
#> }

# Insert at the end of the array. `-1` is treated as an insertion regardless
# of the value of `is_array_insertion`.
cat(text_modify(text, list("foo", -1), 0))
#> {
#>     "[r]": {
#>     },
#>     "foo": [
#>         1,
#>         2,
#>         3,
#>         0
#>     ]
#> }

# Only the modified elements are reformatted
text <- '{"foo":[1,2],\n"bar":1}'
cat(text_modify(text, list("foo", 3), 0))
#> {
#>     "foo": [
#>         1,
#>         2,
#>         0
#>     ],
#> "bar":1}

# You can control how those elements are formatted
cat(text_modify(
  text,
  list("foo", 3),
  0,
  modification_options = modification_options(
    formatting_options = formatting_options(indent_width = 2),
    is_array_insertion = TRUE
  )
))
#> {
#>   "foo": [
#>     1,
#>     2,
#>     0
#>   ],
#> "bar":1}
```
