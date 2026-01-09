# jsonedit

R bindings to
[node-jsonc-parser](https://github.com/microsoft/node-jsonc-parser) to
modify or format JSON files while retaining comments.

## Installation

You can install the development version of jsonedit like so:

``` r
pak::pak("r-lib/jsonedit")
```

## Example

``` r
library(jsonedit)

text <- '
{
  "[r]": {
    // Important comment
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "Posit.air-vscode"
  },
  "files.trimFinalNewlines": true,
  "editor.rulers": [
    80,
    100
  ], // A trailing comma
}
'
```

Parse an entire file worth of text with
[`text_parse()`](https://jsonedit.r-lib.org/reference/parse.md) or
[`file_parse()`](https://jsonedit.r-lib.org/reference/parse.md):

``` r
text_parse(text)
#> $`[r]`
#> $`[r]`$editor.formatOnSave
#> [1] TRUE
#> 
#> $`[r]`$editor.defaultFormatter
#> [1] "Posit.air-vscode"
#> 
#> 
#> $files.trimFinalNewlines
#> [1] TRUE
#> 
#> $editor.rulers
#> $editor.rulers[[1]]
#> [1] 80
#> 
#> $editor.rulers[[2]]
#> [1] 100
```

Parse a target JSON path with
[`text_parse_at_path()`](https://jsonedit.r-lib.org/reference/parse.md)
or
[`file_parse_at_path()`](https://jsonedit.r-lib.org/reference/parse.md):

``` r
text_parse_at_path(text, c("[r]", "editor.formatOnSave"))
#> [1] TRUE

# The 2nd ruler in the array
text_parse_at_path(text, list("editor.rulers", 2))
#> [1] 100
```

Modify a JSON file, retaining comments, using
[`text_modify()`](https://jsonedit.r-lib.org/reference/modify.md) and
[`file_modify()`](https://jsonedit.r-lib.org/reference/modify.md):

``` r
# A new field
cat(text_modify(text, "new", 1))
#> 
#> {
#>   "[r]": {
#>     // Important comment
#>     "editor.formatOnSave": true,
#>     "editor.defaultFormatter": "Posit.air-vscode"
#>   },
#>   "files.trimFinalNewlines": true,
#>   "editor.rulers": [
#>     80,
#>     100
#> ],
#> "new": 1, // A trailing comma
#> }

# Modify an existing path, retaining comments
cat(text_modify(text, c("[r]", "editor.formatOnSave"), FALSE))
#> 
#> {
#>   "[r]": {
#>     // Important comment
#>     "editor.formatOnSave": false,
#>     "editor.defaultFormatter": "Posit.air-vscode"
#>   },
#>   "files.trimFinalNewlines": true,
#>   "editor.rulers": [
#>     80,
#>     100
#>   ], // A trailing comma
#> }

# Modify an array by position

# Replacement:
cat(text_modify(text, list("editor.rulers", 2), 20))
#> 
#> {
#>   "[r]": {
#>     // Important comment
#>     "editor.formatOnSave": true,
#>     "editor.defaultFormatter": "Posit.air-vscode"
#>   },
#>   "files.trimFinalNewlines": true,
#>   "editor.rulers": [
#>     80,
#>     20
#>   ], // A trailing comma
#> }

# Insertion:
options <- modification_options(is_array_insertion = TRUE)
cat(text_modify(
  text,
  list("editor.rulers", 2),
  20,
  modification_options = options
))
#> 
#> {
#>   "[r]": {
#>     // Important comment
#>     "editor.formatOnSave": true,
#>     "editor.defaultFormatter": "Posit.air-vscode"
#>   },
#>   "files.trimFinalNewlines": true,
#>   "editor.rulers": [
#>     80,
#>     20,
#>     100
#>   ], // A trailing comma
#> }

# Insertion at back (when you don't know the number of existing elements)
cat(text_modify(text, list("editor.rulers", -1), 20))
#> 
#> {
#>   "[r]": {
#>     // Important comment
#>     "editor.formatOnSave": true,
#>     "editor.defaultFormatter": "Posit.air-vscode"
#>   },
#>   "files.trimFinalNewlines": true,
#>   "editor.rulers": [
#>     80,
#>     100,
#>     20
#>   ], // A trailing comma
#> }
```
