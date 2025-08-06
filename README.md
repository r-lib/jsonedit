# jsonedit

R bindings to [node-jsonc-parser](https://github.com/microsoft/node-jsonc-parser)
to modify or format JSON files while retaining comments and whitespace.

## Example

How it works:

``` r
library(jsonedit)

# update field on existing settings.json
json_modify_file('settings.json', c('[r]', 'editor.formatOnSave'), TRUE)

# some example operationgs
unlink('test.json')
json_modify_file('test.json', 'title', "This is a test")
json_modify_file('test.json', c("foo", "bar"), 1:3)
json_modify_file('test.json', c("foo", "baz"), TRUE)
json_modify_file('test.json', list("foo", "bar", 1), 9999)
```

