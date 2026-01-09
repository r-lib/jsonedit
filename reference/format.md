# Format a JSON file or string

Format a JSON file or string, preserving comments.

## Usage

``` r
text_format(text, ..., formatting_options = NULL)

file_format(file, ..., formatting_options = NULL)

formatting_options(
  indent_width = 4L,
  indent_style = "space",
  eol = "\n",
  insert_final_newline = TRUE
)
```

## Arguments

- text:

  A single string containing JSON.

- ...:

  These dots are for future extensions and must be empty.

- formatting_options:

  The result of `formatting_options()`. If `NULL`, a default set of
  options are used.

- file:

  Path to file on disk. File must exist.

- indent_width:

  The number of spaces to use to indicate a single indent when
  `indent_style = "space"`.

- indent_style:

  The style of indentation to use. Either:

  - `"space"` for spaces.

  - `"tab"` for tabs.

- eol:

  The character used for the end of a line. This is only applicable when
  the text doesn't already contain an existing line ending, i.e. an
  empty string or a string spanning a single line.

- insert_final_newline:

  Whether or not to insert a final newline.

## Examples

``` r
text <- '{"foo":[1,2]}'
cat(text_format(text))
#> {
#>     "foo": [
#>         1,
#>         2
#>     ]
#> }

formatting_options <- formatting_options(indent_width = 2)
cat(text_format(text, formatting_options = formatting_options))
#> {
#>   "foo": [
#>     1,
#>     2
#>   ]
#> }
```
