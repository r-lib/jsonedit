# Parse a JSON file or string

- `text_parse()` and `file_parse()` parse JSON into an R object.

- `text_parse_at_path()` and `file_parse_at_path()` parse JSON at a
  requested JSON path, i.e. `c("[r]", "editor.formatOnSave")`.

## Usage

``` r
text_parse(text, ..., parse_options = NULL)

file_parse(file, ..., parse_options = NULL)

text_parse_at_path(text, path, ..., parse_options = NULL)

file_parse_at_path(file, path, ..., parse_options = NULL)

parse_options(
  allow_comments = TRUE,
  allow_trailing_comma = TRUE,
  allow_empty_content = TRUE
)
```

## Arguments

- text:

  A single string containing JSON.

- ...:

  These dots are for future extensions and must be empty.

- parse_options:

  The result of `parse_options()`. If `NULL`, a default set of options
  are used.

- file:

  Path to file on disk. File must exist.

- path:

  Either:

  - A character vector representing a path to a JSON element by name,
    i.e. `c("[r]", "editor.formatOnSave")`.

  - A list of strings or numbers representing a path to a JSON element
    by name and position, i.e. `list("[r]", "editor.rulers", 2)`.

  Numeric positions are specified as positive integers and are only
  applicable for arrays.

- allow_comments:

  Whether or not to allow comments when parsing.

- allow_trailing_comma:

  Whether or not to allow a trailing comma when parsing.

- allow_empty_content:

  Whether or not to allow empty strings or empty files when parsing.

## Examples

``` r
text <- '
{
  "a": 1,
  "b": [2, 3, 4],
  "[r]": {
    "this": "setting",
    // A comment!
    "that": true
  }, // A trailing comma!
}
'

# Parse the JSON, allowing comments (i.e. JSONC)
str(text_parse(text))
#> List of 3
#>  $ a  : int 1
#>  $ b  :List of 3
#>   ..$ : int 2
#>   ..$ : int 3
#>   ..$ : int 4
#>  $ [r]:List of 2
#>   ..$ this: chr "setting"
#>   ..$ that: logi TRUE

# Try to parse the JSON, but comments aren't allowed!
parse_options <- parse_options(allow_comments = FALSE)
try(text_parse(text, parse_options = parse_options))
#> Error in text_parse(text, parse_options = parse_options) : 
#>   Can't parse when there are parse errors.
#> ℹ Invalid comment token
#>     "this": "setting",
#>     // A comment!
#>     "that": true
#>   
#> ℹ Invalid comment token
#>     "that": true
#>   }, // A trailing comma!
#> }
#> 

# Try to parse the JSON, but trailing commas aren't allowed!
parse_options <- parse_options(allow_trailing_comma = FALSE)
try(text_parse(text, parse_options = parse_options))
#> Error in text_parse(text, parse_options = parse_options) : 
#>   Can't parse when there are parse errors.
#> ℹ Property name expected
#>   }, // A trailing comma!
#> }
#> 
#> ℹ Value expected
#>   }, // A trailing comma!
#> }
#> 

# Parse only a subset of the JSON
text_parse_at_path(text, "b")
#> [[1]]
#> [1] 2
#> 
#> [[2]]
#> [1] 3
#> 
#> [[3]]
#> [1] 4
#> 
text_parse_at_path(text, "[r]")
#> $this
#> [1] "setting"
#> 
#> $that
#> [1] TRUE
#> 
text_parse_at_path(text, c("[r]", "that"))
#> [1] TRUE

# Use a `list()` combining strings and positional indices when
# arrays are involved
text_parse_at_path(text, list("b", 2))
#> [1] 3
```
